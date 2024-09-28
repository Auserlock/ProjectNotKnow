use iced::widget::*;
use iced::Length;
use log::{error, info};
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

struct Counter {
    text: text_editor::Content,
    author: text_editor::Content,
    source: text_editor::Content,
    page: text_editor::Content,
    digests: Vec<text_editor::Content>,
}

impl Default for Counter {
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

impl Counter {
    fn update(&mut self, message: Message) {
        match message {
            Message::AddDigest => {
                self.digests.push(text_editor::Content::default());
            }
            Message::DeleteDigest => {
                self.digests.pop();
            }
            Message::Submit => {
                let text = format!("\"{}\"", self.text.text());
                let author = format!("\"{}\"", self.author.text());
                let source = format!("\"{}\"", self.source.text());
                let page = self.page.text();
                let digests = self
                    .digests
                    .iter()
                    .map(|digest| digest.text())
                    .collect::<Vec<_>>();

                let insert = Command::new("insert")
                    .arg(text)
                    .arg(author)
                    .arg(source)
                    .arg(page)
                    .args(digests)
                    .output();

                match insert {
                    Ok(output) => info!("{}", String::from_utf8_lossy(&output.stdout)),
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
        let mut children = vec![
            vertical_space().height(Length::Fixed(20.0)).into(),
            text_editor(&self.text)
                .on_action(Message::TextEditor)
                .placeholder("Write a text here")
                .into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
            text_editor(&self.author)
                .on_action(Message::AuthorEditor)
                .placeholder("Write an author here")
                .into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
            text_editor(&self.source)
                .on_action(Message::SourceEditor)
                .placeholder("Write a source here")
                .into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
            text_editor(&self.page)
                .on_action(Message::PageEditor)
                .placeholder("Write a page here")
                .into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
            buttons.into(),
            vertical_space().height(Length::Fixed(20.0)).into(),
        ];

        children.extend(self.digests.iter().enumerate().map(|(index, digest)| {
            text_editor(digest)
                .on_action(move |action| Message::DigestEditor(index, action))
                .placeholder("Write a digest here")
                .into()
        }));

        children.push(button("Submit").on_press(Message::Submit).into());

        let children = vec![
            horizontal_space().width(Length::Fixed(20.0)).into(),
            Column::with_children(children).into(),
            horizontal_space().width(Length::Fixed(20.0)).into(),
        ];

        column.push(Row::with_children(children)).into()
    }
}

fn main() {
    pretty_env_logger::init();
    iced::application("counter", Counter::update, Counter::view)
        .run()
        .unwrap();
}
