use iced::widget::*;
use iced::window::Settings;
use iced::{Length, Size};
use log::{error, info, warn};
use std::ffi::OsStr;
use std::process::Command;

#[derive(Debug, Clone)]
enum Message {
    AddDigest,
    DeleteDigest,
    Submit,
    TextEditor(text_editor::Action),
    AuthorEditor(text_editor::Action),
    SourceEditor(text_editor::Action),
    PageEditor(text_editor::Action),
    DigestEditor(usize, text_editor::Action),
}

struct Reine {
    text: text_editor::Content,
    author: text_editor::Content,
    source: text_editor::Content,
    page: text_editor::Content,
    digests: Vec<text_editor::Content>,
}

impl Default for Reine {
    fn default() -> Self {
        Self {
            text: text_editor::Content::default(),
            author: text_editor::Content::default(),
            source: text_editor::Content::default(),
            page: text_editor::Content::default(),
            digests: vec![text_editor::Content::default()],
        }
    }
}

impl Reine {
    fn update(&mut self, message: Message) {
        match message {
            Message::AddDigest => {
                self.digests.push(text_editor::Content::default());
            }
            Message::DeleteDigest => {
                if self.digests.len() == 1 {
                    warn!("There is only one digest, it cannot be deleted");
                    return;
                }
                self.digests.pop();
            }
            Message::Submit => {
                let mut need_executing = true;

                let mut raw_text = self.text.text();
                raw_text.retain(|c| !c.is_whitespace());
                if raw_text.is_empty() {
                    warn!("The text is empty");
                    need_executing = false;
                }

                let pages = self
                    .page
                    .text()
                    .split_whitespace()
                    .map(|s| s.to_string())
                    .collect::<Vec<_>>();

                let page = if pages.len() > 1 {
                    warn!("The page has more than one word");
                    need_executing = false;
                    0
                } else {
                    let page = pages[0].parse::<usize>();
                    let page = match page {
                        Ok(page) => page,
                        Err(e) => {
                            warn!("The page is not a number: {}", e);
                            need_executing = false;
                            0
                        }
                    };
                    page
                };

                let mut raw_source = self.source.text();
                raw_source.retain(|c| !c.is_whitespace());
                if raw_source.is_empty() {
                    warn!("The source is empty");
                    need_executing = false;
                }

                if self.digests.is_empty() {
                    warn!("The digests are empty");
                    need_executing = false;
                } else {
                    for (i, digest) in self.digests.iter().enumerate() {
                        let mut raw_digest = digest.text();
                        raw_digest.retain(|c| !c.is_whitespace());
                        if raw_digest.is_empty() {
                            warn!("The digest {} is empty", i);
                            need_executing = false;
                        }
                    }
                }

                if need_executing == false {
                    warn!("Some fields are empty, the process will not be executed");
                    return;
                }

                let text = format!("\"{}\"", self.text.text());
                let mut author = format!("\"{}\"", self.author.text());
                author.retain(|c| c != '\n' && c != '\r' && c != '\t');
                let mut source = format!("\"{}\"", self.source.text());
                source.retain(|c| c != '\n' && c != '\r' && c != '\t');
                let digests = self
                    .digests
                    .iter()
                    .map(|digest| {
                        let mut digest = digest.text();
                        digest.retain(|c| !c.is_whitespace());
                        digest
                    })
                    .collect::<Vec<_>>();

                info!("Executing insert command with the following arguments:");
                info!(
                    "{} {} {} {} {}",
                    text,
                    author,
                    source,
                    page,
                    digests.join(" ")
                );

                let insert = Command::new("insert")
                    .arg(text)
                    .arg(author)
                    .arg(source)
                    .arg(OsStr::new(&page.to_string()))
                    .args(digests)
                    .output();

                match insert {
                    Ok(output) => {
                        error!("{}", String::from_utf8_lossy(&output.stderr));
                        info!("{}", String::from_utf8_lossy(&output.stdout));
                        match output.status.code() {
                            Some(code) => {
                                if code == 0 {
                                    info!("The process was successful with code 0");
                                } else {
                                    error!("The process failed with code {}", code);
                                }
                            }
                            None => {
                                warn!("The process was terminated by a signal");
                            }
                        }
                    }
                    Err(e) => {
                        error!("{}", e);
                    }
                }

                self.text = text_editor::Content::default();
                self.author = text_editor::Content::default();
                self.source = text_editor::Content::default();
                self.page = text_editor::Content::default();
                self.digests = vec![text_editor::Content::default()];
            }
            Message::TextEditor(action) => {
                self.text.perform(action);
            }
            Message::AuthorEditor(action) => {
                self.author.perform(action);
            }
            Message::SourceEditor(action) => {
                self.source.perform(action);
            }
            Message::PageEditor(action) => {
                self.page.perform(action);
            }
            Message::DigestEditor(index, action) => {
                if let Some(digest) = self.digests.get_mut(index) {
                    digest.perform(action);
                }
            }
        }
    }

    fn view(&self) -> Column<Message> {
        let column = Column::new();

        let buttons = row![
            button("Add Digest").on_press(Message::AddDigest),
            horizontal_space().width(Length::Fixed(20.0)),
            button("Delete Digest").on_press(Message::DeleteDigest),
        ];

        let edit_text = vec![
            vertical_space().height(Length::Fixed(20.0)).into(),
            text("Text").into(),
            vertical_space().height(Length::Fixed(10.0)).into(),
            text_editor(&self.text)
                .on_action(Message::TextEditor)
                .placeholder("Write a text here")
                .height(Length::Fill)
                .into(),
        ];

        let text_column: Column<Message> = Column::with_children(edit_text);

        let source_column = Column::with_children(vec![
            vertical_space().height(Length::Fixed(20.0)).into(),
            text("Author").into(),
            vertical_space().height(Length::Fixed(5.0)).into(),
            text_editor(&self.author)
                .on_action(Message::AuthorEditor)
                .placeholder("Write an author here")
                .height(Length::Fill)
                .into(),
            vertical_space().height(Length::Fixed(5.0)).into(),
            text("Page").into(),
            vertical_space().height(Length::Fixed(5.0)).into(),
            text_editor(&self.page)
                .on_action(Message::PageEditor)
                .placeholder("Write a page here")
                .height(Length::Fill)
                .into(),
            vertical_space().height(Length::Fixed(5.0)).into(),
            text("Source").into(),
            vertical_space().height(Length::Fixed(5.0)).into(),
            text_editor(&self.source)
                .on_action(Message::SourceEditor)
                .placeholder("Write a source here")
                .height(Length::Fill)
                .into(),
        ]);

        let input_row = Row::with_children(vec![
            horizontal_space().width(Length::Fixed(20.0)).into(),
            text_column.into(),
            horizontal_space().width(Length::Fixed(20.0)).into(),
            source_column.into(),
            horizontal_space().width(Length::Fixed(20.0)).into(),
        ])
        .height(Length::FillPortion(1));

        let mut children = vec![
            buttons.into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
        ];

        let mut digests_left = Vec::new();
        let mut digests_right = Vec::new();

        self.digests.iter().enumerate().for_each(|(index, digest)| {
            if index % 2 == 0 {
                digests_left.push(
                    text_editor(digest)
                        .on_action(move |action| Message::DigestEditor(index, action))
                        .placeholder("Write a digest here")
                        .into(),
                );
                digests_left.push(vertical_space().height(Length::Fixed(10.0)).into());
            } else {
                digests_right.push(
                    text_editor(digest)
                        .on_action(move |action| Message::DigestEditor(index, action))
                        .placeholder("Write a digest here")
                        .into(),
                );
                digests_right.push(vertical_space().height(Length::Fixed(10.0)).into());
            }
        });

        let digests_row = Row::with_children(vec![
            Column::with_children(digests_left).into(),
            horizontal_space().width(Length::Fixed(20.0)).into(),
            Column::with_children(digests_right).into(),
        ]);

        children.push(text("Digests").into());
        children.push(vertical_space().height(Length::Fixed(10.0)).into());

        children.push(digests_row.into());

        children.push(vertical_space().height(Length::Fixed(20.0)).into());
        children.push(button("Submit").on_press(Message::Submit).into());

        let children = vec![
            horizontal_space().width(Length::Fixed(20.0)).into(),
            Column::with_children(children).into(),
            horizontal_space().width(Length::Fixed(20.0)).into(),
        ];

        column
            .push(input_row)
            .push(vertical_space().height(Length::Fixed(20.0)))
            .push(Row::with_children(children).height(Length::FillPortion(2)))
            .into()
    }
}

fn main() {
    pretty_env_logger::init();
    iced::application("reine", Reine::update, Reine::view)
        .window(Settings {
            min_size: Some(Size::new(800.0, 600.0)),
            ..Default::default()
        })
        .run()
        .unwrap();
}
