use egui::ViewportBuilder;
use reine::app::App;
use std::sync::Arc;

fn main() -> eframe::Result {
    pretty_env_logger::init();

    let wgpu_options = egui_wgpu::WgpuConfiguration {
        supported_backends: wgpu::Backends::PRIMARY,
        device_descriptor: Arc::new(|adapter| wgpu::DeviceDescriptor {
            label: Some("egui-wgpu"),
            #[cfg(not(target_arch = "wasm32"))]
            required_features: wgpu::Features::all_native_mask() & adapter.features(),
            #[cfg(target_arch = "wasm32")]
            required_features: wgpu::Features::all_webgpu_mask() & adapter.features(),
            required_limits: adapter.limits(),
            ..Default::default()
        }),
        ..Default::default()
    };

    let options = eframe::NativeOptions {
        viewport: ViewportBuilder {
            title: Some("Reine".into()),
            min_inner_size: Some(egui::vec2(800.0, 600.0)),
            ..Default::default()
        },
        renderer: eframe::Renderer::Wgpu,
        wgpu_options,
        ..Default::default()
    };

    eframe::run_native("Reine", options, Box::new(|cc| Ok(Box::new(App::new(cc)))))
}
