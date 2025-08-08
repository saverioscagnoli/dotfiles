use serde::Serialize;

use crate::err::BackendError;

pub trait PayloadData: Serialize {
    fn op(&self) -> OpCode;
}

#[derive(Serialize)]
pub struct Payload<T: PayloadData> {
    pub op: u16,
    pub data: T,
}

impl<T: PayloadData> Payload<T> {
    pub fn new(data: T) -> Self {
        Self {
            op: data.op().into(),
            data,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u16)]
pub enum OpCode {
    Error = 0,
    Sysinfo = 1,
    WindowChanged = 2,
    Workspace = 3,
    SpotifyEvent = 4,
    VolumeEvent = 5,
}

impl From<OpCode> for u16 {
    fn from(op: OpCode) -> u16 {
        op as u16
    }
}

impl TryFrom<u16> for OpCode {
    type Error = BackendError;

    fn try_from(value: u16) -> Result<Self, <OpCode as TryFrom<u16>>::Error> {
        match value {
            0 => Ok(OpCode::Error),
            1 => Ok(OpCode::Sysinfo),
            _ => Err(BackendError::InvalidOpCode(value)),
        }
    }
}
