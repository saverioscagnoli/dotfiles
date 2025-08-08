use serde::Serialize;
use std::process::Stdio;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;

use crate::payload::{OpCode, PayloadData};

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TrackInfo {
    pub title: Option<String>,
    pub artist: Option<String>,
    pub album: Option<String>,
    pub status: String,
    pub position: Option<u64>,
    pub duration: Option<u64>,
    pub volume: Option<String>,
    pub artwork_url: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub enum SpotifyEventKind {
    Request,
    Playing,
    Paused,
    Stopped,
}

impl TryFrom<&str> for SpotifyEventKind {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "request" => Ok(SpotifyEventKind::Request),
            "playing" => Ok(SpotifyEventKind::Playing),
            "paused" => Ok(SpotifyEventKind::Paused),
            "stopped" => Ok(SpotifyEventKind::Stopped),
            _ => Err(format!("Unknown Spotify event kind: {}", value)),
        }
    }
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SpotifyEvent {
    #[serde(rename = "type")]
    pub kind: SpotifyEventKind,
    pub track_info: TrackInfo,
}

impl PayloadData for SpotifyEvent {
    fn op(&self) -> OpCode {
        OpCode::SpotifyEvent
    }
}

pub struct PlayerctlListener {
    player: String,
}

impl PlayerctlListener {
    pub fn new<P: AsRef<str>>(player: P) -> Self {
        Self {
            player: player.as_ref().to_string(),
        }
    }

    pub async fn get_current_track(&self) -> Result<TrackInfo, Box<dyn std::error::Error>> {
        let title = self.get_property("title").await.ok();
        let artist = self.get_property("artist").await.ok();
        let album = self.get_property("album").await.ok();
        let status = self
            .get_property("status")
            .await
            .unwrap_or("Unknown".to_string());
        let position = self
            .get_property("position")
            .await
            .ok()
            .and_then(|p| p.parse::<u64>().ok());
        let duration = self
            .get_property("mpris:length")
            .await
            .ok()
            .and_then(|d| d.parse::<u64>().ok());
        let volume = self.get_property("volume").await.ok();
        let artwork_url = self.get_property("mpris:artUrl").await.ok();

        Ok(TrackInfo {
            title,
            artist,
            album,
            status,
            position,
            duration,
            volume,
            artwork_url,
        })
    }

    async fn get_property(&self, property: &str) -> Result<String, Box<dyn std::error::Error>> {
        let output = Command::new("playerctl")
            .args(["-p", &self.player, "metadata", property])
            .output()
            .await?;

        if output.status.success() {
            Ok(String::from_utf8(output.stdout)?.trim().to_string())
        } else {
            Err("Failed to get property".into())
        }
    }

    // Listen for metadata changes with custom format
    pub async fn listen_for_changes<F>(
        &self,
        mut callback: F,
    ) -> Result<(), Box<dyn std::error::Error>>
    where
        F: FnMut(&str, TrackInfo),
    {
        let mut child = Command::new("playerctl")
            .args([
                "-p", &self.player, 
                "-f", "{{status}}|{{title}}|{{artist}}|{{album}}|{{position}}|{{mpris:length}}|{{volume}}|{{mpris:artUrl}}", 
                "metadata", "--follow"
            ])
            .stdout(Stdio::piped())
            .spawn()?;

        let stdout = child.stdout.take().unwrap();
        let reader = BufReader::new(stdout);
        let mut lines = reader.lines();

        while let Some(line) = lines.next_line().await? {
            if let Ok(track_info) = self.parse_playerctl_output(&line) {
                let event_type = match track_info.status.as_str() {
                    "Playing" => "playing",
                    "Paused" => "paused",
                    "Stopped" => "stopped",
                    _ => "unknown",
                };

                callback(event_type, track_info);
            }
        }

        let _ = child.wait().await;
        Ok(())
    }

    fn parse_playerctl_output(&self, line: &str) -> Result<TrackInfo, Box<dyn std::error::Error>> {
        let parts: Vec<&str> = line.split('|').collect();

        if parts.len() >= 8 {
            Ok(TrackInfo {
                status: parts[0].to_string(),
                title: if parts[1].is_empty() {
                    None
                } else {
                    Some(parts[1].to_string())
                },
                artist: if parts[2].is_empty() {
                    None
                } else {
                    Some(parts[2].to_string())
                },
                album: if parts[3].is_empty() {
                    None
                } else {
                    Some(parts[3].to_string())
                },
                position: if parts[4].is_empty() {
                    None
                } else {
                    Some(parts[4].parse::<u64>()?)
                },
                duration: if parts[5].is_empty() {
                    None
                } else {
                    Some(parts[5].parse::<u64>()?)
                },
                volume: if parts[6].is_empty() {
                    None
                } else {
                    Some(parts[6].to_string())
                },
                artwork_url: if parts[7].is_empty() {
                    None
                } else {
                    Some(parts[7].to_string())
                },
            })
        } else {
            Err("Invalid playerctl output format".into())
        }
    }
}
