pub mod insert_view;

#[derive(Eq, PartialEq, Copy, Clone)]
pub enum CurrentView {
    InsertView,
    SearchView,
}
