use serde::Serialize;
use std::{env, path::PathBuf};
use tokio::{
    io::{AsyncBufReadExt, BufReader},
    net::UnixStream,
};

use crate::{
    err::BackendError,
    payload::{OpCode, Payload, PayloadData},
};

#[derive(Debug, Serialize)]
pub struct WindowChanged {
    title: String,
}

impl PayloadData for WindowChanged {
    fn op(&self) -> OpCode {
        OpCode::WindowChanged
    }
}

#[derive(Debug, Serialize)]
pub enum WorkspaceEventKind {
    Moved,
    Created,
    Destroyed,
}

#[derive(Debug, Serialize)]
pub struct Workspace {
    #[serde(rename = "type")]
    kind: WorkspaceEventKind,
    id: u16,
}

impl PayloadData for Workspace {
    fn op(&self) -> OpCode {
        OpCode::Workspace
    }
}

fn socket_path() -> Result<PathBuf, BackendError> {
    let runtime_dir = env::var("XDG_RUNTIME_DIR").map_err(|_| BackendError::XdgRuntimeDirNotSet)?;

    let signature = env::var("HYPRLAND_INSTANCE_SIGNATURE")
        .map_err(|_| BackendError::HyprlandSignatureNotSet)?;

    let path = PathBuf::from(runtime_dir)
        .join("hypr")
        .join(signature)
        .join(".socket2.sock");

    Ok(path)
}

pub async fn hyprland_events() -> Result<(), BackendError> {
    let path = socket_path()?;
    let stream = UnixStream::connect(path).await?;

    let reader = BufReader::new(stream);
    let mut lines = reader.lines();

    while let Some(line) = lines.next_line().await? {
        let Some((event, data)) = line.split_once(">>") else {
            continue;
        };

        match event {
            "workspace" | "createworkspace" | "destroyworkspace" => {
                let event = Workspace {
                    id: data.parse().unwrap_or(0),
                    kind: match event {
                        "workspace" => WorkspaceEventKind::Moved,
                        "createworkspace" => WorkspaceEventKind::Created,
                        "destroyworkspace" => WorkspaceEventKind::Destroyed,
                        _ => continue,
                    },
                };

                let payload = Payload::new(event);

                println!(
                    "{}",
                    serde_json::to_string(&payload).expect("Failed to serialize event")
                );
            }

            "activewindow" => {
                let event = WindowChanged {
                    title: data.to_string(),
                };
                let payload = Payload::new(event);

                println!(
                    "{}",
                    serde_json::to_string(&payload).expect("Failed to serialize event")
                );
            }

            _ => {}
        }
    }

    Ok(())
}
