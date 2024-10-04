use crate::View;
use egui::*;
use log::{error, info, warn};
use std::process::Command;

pub struct InsertView {
    text: String,
    author: String,
    source: String,
    page_number: String,
    digests: Vec<String>,
}

impl InsertView {
    pub fn new() -> Self {
        Self {
            text: String::new(),
            author: String::new(),
            source: String::new(),
            page_number: String::new(),
            digests: vec![String::new()],
        }
    }
    fn submit_insert(&mut self) {
        let mut needs_insert = true;

        if self.text.is_empty() {
            warn!("Text is empty");
            needs_insert = false;
        }

        if self.source.is_empty() {
            warn!("Source is empty");
            needs_insert = false;
        }

        if self.page_number.is_empty() || self.page_number.contains(|c: char| !c.is_numeric()) {
            warn!("Page number is empty or not a number");
            needs_insert = false;
        }

        if self.digests.iter().any(|digest| digest.is_empty()) {
            warn!("Digest is empty");
            needs_insert = false;
        }

        if needs_insert {
            let insert = Command::new("insert")
                .arg(self.text.clone())
                .arg(self.author.clone())
                .arg(self.source.clone())
                .arg(self.page_number.clone())
                .args(self.digests.clone())
                .output();

            info!(
                "Executing command: insert with args: {} {} {} {} {}",
                self.text,
                self.author,
                self.source,
                self.page_number,
                self.digests.join(" ")
            );

            match insert {
                Ok(output) => {
                    if output.stderr.is_empty() {
                        info!(
                            "Command executed successfully: {}",
                            String::from_utf8_lossy(&output.stdout)
                        );
                    } else {
                        error!(
                            "Failed to execute command: {}",
                            String::from_utf8_lossy(&output.stderr)
                        );
                    }
                    match output.status.code() {
                        None => {
                            warn!("Process exited without a code")
                        }
                        Some(code) => {
                            info!("Process exited with code: {}", code)
                        }
                    }
                    self.text.clear();
                    self.author.clear();
                    self.source.clear();
                    self.page_number.clear();
                    self.digests = vec![String::new()];
                }
                Err(e) => {
                    error!("Failed to execute command: {}", e);
                }
            }
        } else {
            warn!("Some fields are empty, command not executed");
        }
    }
}

impl View for InsertView {
    fn draw(&mut self, ui: &mut Ui) {
        ui.horizontal_centered(|ui| {
            ui.add_space((ui.available_width() - 652.0) * 0.5);
            ScrollArea::vertical().scroll([false, true]).show(ui, |ui| {
                ui.vertical_centered_justified(|ui| {
                    ui.horizontal(|ui| {
                        ui.add_space(20.0);
                        ui.vertical(|ui| {
                            ui.add_space(20.0);
                            ui.label("Text");
                            ui.add_space(10.0);
                            ui.add(
                                TextEdit::multiline(&mut self.text).hint_text("Enter text here"),
                            );
                            ui.add_space(20.0);
                        });
                        ui.add_space(20.0);
                        ui.vertical(|ui| {
                            ui.add_space(20.0);
                            ui.label("Author");
                            ui.add_space(10.0);
                            ui.add(
                                TextEdit::singleline(&mut self.author)
                                    .hint_text("Enter author here"),
                            );
                            ui.add_space(10.0);
                            ui.label("Source");
                            ui.add_space(10.0);
                            ui.add(
                                TextEdit::singleline(&mut self.source)
                                    .hint_text("Enter source here"),
                            );
                            ui.add_space(10.0);
                            ui.label("Page Number");
                            ui.add_space(10.0);
                            ui.add(
                                TextEdit::singleline(&mut self.page_number)
                                    .hint_text("Enter page number here"),
                            );
                            ui.add_space(20.0);
                        });
                        ui.add_space(20.0);
                    });

                    ui.vertical(|ui| {
                        ui.add_space(20.0);
                        ui.horizontal(|ui| {
                            ui.add_space(20.0);
                            let add_digest = ui.add(Button::new("Add Digest"));
                            ui.add_space(20.0);
                            let remove_digest = ui.add(Button::new("Remove Digest"));

                            if add_digest.clicked() {
                                self.digests.push(String::new());
                            }
                            if remove_digest.clicked() && self.digests.len() > 1 {
                                self.digests.pop();
                            }
                        });
                        self.digests
                            .chunks_mut(2)
                            .enumerate()
                            .for_each(|(i, chunks)| {
                                ui.add_space(20.0);
                                ui.horizontal(|ui| {
                                    chunks.iter_mut().enumerate().for_each(|(j, digest)| {
                                        ui.add_space(20.0);
                                        ui.vertical(|ui| {
                                            ui.label(format!("Digest {}", i * 2 + j + 1));
                                            ui.add_space(10.0);
                                            ui.add(
                                                TextEdit::singleline(digest)
                                                    .hint_text("Digest here"),
                                            );
                                        });
                                    });
                                });
                            });
                        ui.add_space(20.0);
                        ui.horizontal(|ui| {
                            ui.add_space(20.0);
                            let submit = ui.add(Button::new("Submit"));
                            if submit.clicked() {
                                self.submit_insert();
                            }
                        });
                    });
                });
            });
        });
    }
}
