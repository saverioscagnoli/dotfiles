use serde::Serialize;

use crate::payload::{OpCode, PayloadData};

#[derive(Debug, Serialize, thiserror::Error)]
pub enum BackendError {
    #[error("Tokio error: {0}")]
    TokioIo(String),

    #[error("XDG_RUNTIME_DIR environment variable is not set")]
    XdgRuntimeDirNotSet,

    #[error("HYPRLAND_INSTANCE_SIGNATURE environment variable is not set")]
    HyprlandSignatureNotSet,

    #[error("Invalid OpCode: {0}")]
    InvalidOpCode(u16),
}

impl From<tokio::io::Error> for BackendError {
    fn from(err: tokio::io::Error) -> Self {
        BackendError::TokioIo(err.to_string())
    }
}

impl PayloadData for BackendError {
    fn op(&self) -> OpCode {
        OpCode::Error
    }
}
