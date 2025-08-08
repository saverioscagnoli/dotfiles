use crate::payload::{OpCode, Payload, PayloadData};
use serde::Serialize;
use std::process::Stdio;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;

#[derive(Debug, Clone, Serialize)]
pub struct VolumeEvent {
    pub volume: u32,
}

impl PayloadData for VolumeEvent {
    fn op(&self) -> OpCode {
        OpCode::VolumeEvent
    }
}

pub async fn monitor_volume_changes() -> Result<(), Box<dyn std::error::Error>> {
    // Subscribe to PulseAudio events
    let mut child = Command::new("pactl")
        .args(&["subscribe"])
        .stdout(Stdio::piped())
        .spawn()?;

    let stdout = child.stdout.take().unwrap();
    let reader = BufReader::new(stdout);
    let mut lines = reader.lines();

    while let Some(line) = lines.next_line().await? {
        // Check if the event is related to sink (output device) changes
        if line.contains("'change' on sink") {
            if let Ok(volume) = get_current_volume().await {
                let event = VolumeEvent { volume };
                let payload = Payload::new(event);

                println!(
                    "{}",
                    serde_json::to_string(&payload).expect("Failed to serialize volume event")
                );
            }
        }
    }

    Ok(())
}

async fn get_current_volume() -> Result<u32, Box<dyn std::error::Error>> {
    let output = Command::new("pactl")
        .args(&["get-sink-volume", "@DEFAULT_SINK@"])
        .output()
        .await?;

    let output_str = String::from_utf8(output.stdout)?;

    // Parse volume percentage from output like "Volume: front-left: 65536 /  100% / 0.00 dB"
    if let Some(percent_pos) = output_str.find('%') {
        let before_percent = &output_str[..percent_pos];
        if let Some(space_pos) = before_percent.rfind(' ') {
            let volume_str = &before_percent[space_pos + 1..];
            return Ok(volume_str.parse()?);
        }
    }

    Err("Could not parse volume".into())
}
