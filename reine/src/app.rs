use crate::views::insert_view::InsertView;
use crate::views::CurrentView;
use crate::View;
use eframe::epaint::FontFamily;
use eframe::Frame;
use egui::*;

pub struct App {
    current_view: CurrentView,
    insert_view: InsertView,
}

impl App {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        let egui_ctx = &cc.egui_ctx;

        let mut fonts = FontDefinitions::default();

        fonts.font_data.insert(
            "SF-Mono-Regular".into(),
            FontData::from_static(include_bytes!("../assets/fonts/SF-Mono-Regular.otf")),
        );
        fonts.font_data.insert(
            "SF-Pro-Display-Regular".into(),
            FontData::from_static(include_bytes!("../assets/fonts/SF-Pro-Display-Regular.otf")),
        );
        fonts.font_data.insert(
            "PingFangSC-Regular".into(),
            FontData::from_static(include_bytes!("../assets/fonts/PingFangSC-Regular.otf")),
        );

        fonts
            .families
            .entry(FontFamily::Monospace)
            .or_default()
            .insert(0, "SF-Mono-Regular".into());

        fonts
            .families
            .entry(FontFamily::Proportional)
            .or_default()
            .insert(0, "SF-Pro-Display-Regular".into());

        fonts
            .families
            .entry(FontFamily::Monospace)
            .or_default()
            .insert(1, "PingFangSC-Regular".into());

        fonts
            .families
            .entry(FontFamily::Proportional)
            .or_default()
            .insert(1, "PingFangSC-Regular".into());

        egui_ctx.set_fonts(fonts);

        egui_extras::install_image_loaders(egui_ctx);
        Self {
            current_view: CurrentView::InsertView,
            insert_view: InsertView::new(),
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &Context, _frame: &mut Frame) {
        let screen_size = ctx.screen_rect();
        SidePanel::left("Left Panel")
            .max_width((screen_size.width() * 0.18).min(120.0))
            .show(ctx, |ui| {
                ScrollArea::vertical().scroll([false, true]).show(ui, |ui| {
                    ui.add_space(20.0);
                    Grid::new("Options")
                        .num_columns(1)
                        .spacing([5.0, 5.0])
                        .striped(true)
                        .show(ui, |ui| {
                            ui.with_layout(
                                Layout::left_to_right(Align::LEFT).with_main_justify(true),
                                |ui| {
                                    let insert = ui.add(SelectableLabel::new(
                                        self.current_view == CurrentView::InsertView,
                                        "Insert",
                                    ));
                                    if insert.clicked() {
                                        self.current_view = CurrentView::InsertView;
                                    }
                                },
                            );
                            ui.end_row();
                            ui.with_layout(
                                Layout::left_to_right(Align::LEFT).with_main_justify(true),
                                |ui| {
                                    let search = ui.add(SelectableLabel::new(
                                        self.current_view == CurrentView::SearchView,
                                        "Search",
                                    ));
                                    if search.clicked() {
                                        self.current_view = CurrentView::SearchView;
                                    }
                                },
                            );
                            ui.end_row();
                        });
                });
            });
        CentralPanel::default().show(ctx, |ui| match self.current_view {
            CurrentView::InsertView => {
                self.insert_view.draw(ui);
            }
            CurrentView::SearchView => {}
        });
    }
}
