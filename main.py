from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.popup import Popup
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.boxlayout import BoxLayout

# Definicja ekranów
class MainScreen(Screen):
    pass

class SummaryScreen(Screen):
    pass

class RoundScreen(Screen):
    pass

class WorkTrackerApp(App):
    def build(self):
        return Builder.load_file("worktracker.kv")

    def scan_display(self):
        print("Skanowanie wyświetlacza...")

    def show_alert(self, message):
        layout = BoxLayout(orientation='vertical', padding=10)
        label = Label(text=message, size_hint_y=None, height=100)
        button = Button(text="OK", size_hint_y=None, height="50dp")

        layout.add_widget(label)
        layout.add_widget(button)

        popup = Popup(title="Informacja", content=layout, size_hint=(None, None), size=(300, 200))
        button.bind(on_release=popup.dismiss)
        popup.open()

    def show_summary(self):
        self.root.current = "summary"

    def switch_to_main(self):
        self.root.current = "main"

if __name__ == "__main__":
    WorkTrackerApp().run()
