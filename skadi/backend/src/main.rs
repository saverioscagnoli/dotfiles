mod err;
mod hyprland;
mod payload;
mod spotify;
mod sysinfo;
mod volume;

use crate::err::BackendError;
use crate::hyprland::hyprland_events;
use crate::payload::Payload;
use crate::spotify::{PlayerctlListener, SpotifyEvent, SpotifyEventKind};
use crate::sysinfo::poll_sysinfo;
use crate::volume::monitor_volume_changes;
use clap::Parser;
use std::time::Duration;

#[derive(Debug, Parser)]
pub struct Args {
    #[arg(long, default_value = "5")]
    pub sysinfo_poll_interval: u64,
}

#[tokio::main]
async fn main() -> Result<(), BackendError> {
    let args = Args::parse();

    let sysinfo_handle = tokio::spawn(async move {
        let interval = Duration::from_secs(args.sysinfo_poll_interval);
        poll_sysinfo(interval).await
    });

    let hyprland_handle = tokio::spawn(async move {
        if let Err(e) = hyprland_events().await {
            eprintln!("Error in Hyprland events: {}", e);
        }
    });

    let spotify_handle = tokio::spawn(async move {
        let listener = PlayerctlListener::new("spotify");

        if let Ok(track_info) = listener.get_current_track().await {
            let event = SpotifyEvent {
                kind: SpotifyEventKind::Request,
                track_info,
            };
            let payload = Payload::new(event);

            println!(
                "{}",
                serde_json::to_string(&payload).expect("Failed to serialize Spotify event")
            );
        }

        if let Err(e) = listener
            .listen_for_changes(|e, info| {
                let event = SpotifyEvent {
                    kind: SpotifyEventKind::try_from(e).unwrap_or(SpotifyEventKind::Stopped),
                    track_info: info,
                };

                let payload = Payload::new(event);

                println!(
                    "{}",
                    serde_json::to_string(&payload).expect("Failed to serialize Spotify event")
                );
            })
            .await
        {
            eprintln!("Error in Spotify listener: {}", e);
        }
    });

    tokio::select! {
        _ = sysinfo_handle => {},
        _ = hyprland_handle => {},
        _ = spotify_handle => {},
        _ = monitor_volume_changes() => {},
    }

    Ok(())
}

// fn handle_hyprland_event(event_line: &str) {
//     // Parse the event line format: "EVENT>>DATA"
//     if let Some((event_type, event_data)) = event_line.split_once(">>") {
//         match event_type {
//             "workspace" => {
//                 println!("🖥️  Workspace changed: {}", event_data);
//             }
//             "focusedmon" => {
//                 println!("🖱️  Monitor focus changed: {}", event_data);
//             }
//             "activewindow" => {
//                 println!("🪟  Active window changed: {}", event_data);
//             }
//             "activewindowv2" => {
//                 println!("🪟  Active window changed (v2): {}", event_data);
//             }
//             "fullscreen" => {
//                 println!("⛶  Fullscreen toggled: {}", event_data);
//             }
//             "monitorremoved" => {
//                 println!("📺  Monitor removed: {}", event_data);
//             }
//             "monitoradded" => {
//                 println!("📺  Monitor added: {}", event_data);
//             }
//             "createworkspace" => {
//                 println!("➕  Workspace created: {}", event_data);
//             }
//             "destroyworkspace" => {
//                 println!("➖  Workspace destroyed: {}", event_data);
//             }
//             "moveworkspace" => {
//                 println!("🔄  Workspace moved: {}", event_data);
//             }
//             "renameworkspace" => {
//                 println!("📝  Workspace renamed: {}", event_data);
//             }
//             "activelayout" => {
//                 println!("📐  Layout changed: {}", event_data);
//             }
//             "openwindow" => {
//                 println!("🆕  Window opened: {}", event_data);
//             }
//             "closewindow" => {
//                 println!("❌  Window closed: {}", event_data);
//             }
//             "movewindow" => {
//                 println!("↔️  Window moved: {}", event_data);
//             }
//             "openlayer" => {
//                 println!("🔗  Layer opened: {}", event_data);
//             }
//             "closelayer" => {
//                 println!("🔗  Layer closed: {}", event_data);
//             }
//             "submap" => {
//                 println!("🗺️  Submap changed: {}", event_data);
//             }
//             "changefloatingmode" => {
//                 println!("🎈  Floating mode changed: {}", event_data);
//             }
//             "urgent" => {
//                 println!("⚠️  Urgent window: {}", event_data);
//             }
//             "minimize" => {
//                 println!("📉  Window minimized: {}", event_data);
//             }
//             "screencast" => {
//                 println!("📹  Screencast event: {}", event_data);
//             }
//             "windowtitle" => {
//                 println!("📄  Window title changed: {}", event_data);
//             }
//             _ => {
//                 println!("❓  Unknown event: {} >> {}", event_type, event_data);
//             }
//         }
//     } else {
//         println!("⚠️  Malformed event line: {}", event_line);
//     }
// }
