use crate::payload::{OpCode, Payload, PayloadData};
use serde::Serialize;
use std::time::Duration;
use sysinfo::{Disks, Networks, System};

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SysinfoPayload {
    pub cpu_usage: f32,
    pub memory_used: u64,
    pub memory_total: u64,
    pub memory_free: u64,
    pub swap_used: u64,
    pub swap_total: u64,
    pub network_rx: u64,
    pub network_tx: u64,
    pub disk_read: u64,
    pub disk_write: u64,
    pub disk_usage: u64,
    pub disk_total: u64,
    pub disk_free: u64,
}

impl PayloadData for SysinfoPayload {
    fn op(&self) -> OpCode {
        OpCode::Sysinfo
    }
}

pub async fn poll_sysinfo(interval: Duration) -> ! {
    let mut system = System::new_all();
    let mut networks = Networks::new();
    let mut disks = Disks::new();
    let mut interval = tokio::time::interval(interval);

    loop {
        interval.tick().await;

        system.refresh_all();
        networks.refresh(true);
        disks.refresh(true);

        let network_values = networks.values().collect::<Vec<_>>();
        let disks = disks.list();

        let mut disk_read = 0;
        let mut disk_write = 0;
        let mut disk_usage = 0;
        let mut disk_total = 0;
        let mut disk_free = 0;

        // Find the root disk (/)
        if let Some(root_disk) = disks
            .iter()
            .find(|disk| disk.mount_point().to_str() == Some("/"))
        {
            let usage = root_disk.usage();

            disk_read = usage.read_bytes;
            disk_write = usage.written_bytes;
            disk_usage = root_disk.total_space() - root_disk.available_space();
            disk_total = root_disk.total_space();
            disk_free = root_disk.available_space();
        }

        let payload = SysinfoPayload {
            cpu_usage: system.global_cpu_usage(),
            memory_used: system.used_memory(),
            memory_total: system.total_memory(),
            memory_free: system.available_memory(),
            swap_used: system.used_swap(),
            swap_total: system.total_swap(),
            network_rx: network_values.iter().map(|n| n.received()).sum(),
            network_tx: network_values.iter().map(|n| n.transmitted()).sum(),
            disk_read,
            disk_write,
            disk_usage,
            disk_total,
            disk_free,
        };

        println!(
            "{}",
            serde_json::to_string(&Payload::new(payload))
                .expect("Failed to serialize sysinfo payload")
        );
    }
}
