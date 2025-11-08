import speech_recognition as sr
import pyttsx3
import wikipedia
import webbrowser
import datetime

# Initialize text-to-speech
engine = pyttsx3.init()

def speak(text):
    engine.say(text)
    engine.runAndWait()

def listen():
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("Listening...")
        r.adjust_for_ambient_noise(source)
        try:
            audio = r.listen(source, timeout=5, phrase_time_limit=10)
            print("Recognizing...")
            query = r.recognize_google(audio, language='en-in')
            print(f"You said: {query}")
            return query.lower()
        except sr.WaitTimeoutError:
            print("No speech detected, listening again...")
            return ""
        except Exception as e:
            print("Could not understand audio, try again...")
            return ""

if __name__ == "__main__":
    try:
        speak("Hello, I am your voice assistant. How can I help you?")
        while True:
            query = listen()
            if not query:
                continue  # listen again if nothing detected

            if 'wikipedia' in query:
                speak("Searching Wikipedia...")
                try:
                    query_text = query.replace("wikipedia", "")
                    results = wikipedia.summary(query_text, sentences=2)
                    speak("According to Wikipedia")
                    print(results)
                    speak(results)
                except Exception as e:
                    print("Wikipedia search failed:", e)
                    speak("Sorry, I could not find that on Wikipedia.")

            elif 'open youtube' in query:
                speak("Opening YouTube")
                webbrowser.open("https://www.youtube.com")

            elif 'open google' in query:
                speak("Opening Google")
                webbrowser.open("https://www.google.com")

            elif 'time' in query:
                strTime = datetime.datetime.now().strftime("%H:%M:%S")
                speak(f"The time is {strTime}")

            elif 'exit' in query or 'quit' in query:
                speak("Goodbye!")
                break

            else:
                speak("I am sorry, I did not understand that. Please try again.")

    except Exception as e:
        print("An unexpected error occurred:", e)
        speak("An error occurred, exiting now.")




