from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen

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
        # Tu możesz umieścić kod obsługujący skanowanie wyświetlacza
        print("Skanowanie wyświetlacza...")
    
    def show_alert(self, message):
        # Na razie wyświetlamy komunikat w konsoli
        print("Alert:", message)
    
    def show_summary(self):
        self.root.current = "summary"
    
    def switch_to_main(self):
        self.root.current = "main"

if __name__ == "__main__":
    WorkTrackerApp().run()
