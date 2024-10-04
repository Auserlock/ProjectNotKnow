use egui::Ui;

pub mod app;
pub mod views;

pub trait View {
    fn draw(&mut self, ui: &mut Ui);
}
