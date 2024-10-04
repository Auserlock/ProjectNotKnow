use egui::Ui;

pub mod insert_view;

#[derive(Eq, PartialEq, Copy, Clone)]
pub enum CurrentView {
    InsertView,
    SearchView,
}

pub trait View {
    fn draw(&mut self, ui: &mut Ui);
}
