# Screenshot Instructions for Widget Tree Assignment

## 📸 Required Screenshots for Documentation

To complete the assignment, capture the following screenshots showing before-and-after states:

### Screenshot Set 1: Initial State
**Filename:** `01_initial_state.png`

**What to show:**
- App launched with Widget Tree Demo Screen
- Counter at 0
- Light mode active (white background)
- Blue theme color selected
- No extra widget visible

**How to capture:**
1. Open the app
2. Take a full-screen screenshot
3. Save to `screenshots/` folder

---

### Screenshot Set 2: Counter Incremented
**Filename:** `02_counter_incremented.png`

**What to show:**
- Counter at 15 (to show green icon change)
- Click increment button multiple times
- Notice icon turns green when counter > 10

**How to capture:**
1. Click "Increment" button 15 times
2. Take screenshot
3. Shows reactive state update

---

### Screenshot Set 3: Dark Mode Active
**Filename:** `03_dark_mode_active.png`

**What to show:**
- Dark background (gray-900)
- Dark cards (gray-800)
- Light text colors
- Dark mode icon displayed

**How to capture:**
1. Click "Switch to Dark" button
2. Take screenshot
3. Shows multiple widgets updating simultaneously

---

### Screenshot Set 4: Color Changed
**Filename:** `04_color_changed_purple.png`

**What to show:**
- Purple color selected
- AppBar is purple
- All buttons are purple
- Color preview box shows purple
- Purple icon colors

**How to capture:**
1. Tap the purple color circle
2. Take screenshot
3. Shows color state affecting multiple widgets

---

### Screenshot Set 5: Extra Widget Visible
**Filename:** `05_extra_widget_visible.png`

**What to show:**
- Toggle switch ON
- Celebration icon and "I'm a dynamic widget!" visible
- Animated container expanded

**How to capture:**
1. Toggle "Show Extra Widget" switch ON
2. Take screenshot
3. Shows conditional rendering

---

### Screenshot Set 6: Combined State Changes
**Filename:** `06_combined_state.png`

**What to show:**
- Counter at high number (e.g., 25)
- Dark mode ON
- Orange or green color selected
- Extra widget visible

**How to capture:**
1. Apply multiple state changes together
2. Take screenshot
3. Shows complex state management

---

## 📁 Folder Structure

Create a `screenshots/` folder in your project root:

```
customerloop/
  ┣ screenshots/
  ┃  ┣ 01_initial_state.png
  ┃  ┣ 02_counter_incremented.png
  ┃  ┣ 03_dark_mode_active.png
  ┃  ┣ 04_color_changed_purple.png
  ┃  ┣ 05_extra_widget_visible.png
  ┃  ┗ 06_combined_state.png
  ┗ ...
```

---

## 🎥 Video Recording Instructions

### Duration: 1-2 minutes

### Video Script:

1. **Introduction (10 seconds)**
   - "Hello, this is the Widget Tree and Reactive UI demo"
   - "I'll show how Flutter's widget tree and reactive model work"

2. **Show Widget Hierarchy (15 seconds)**
   - Open `widget_tree_demo_screen.dart` in VS Code
   - Scroll through the code comments showing tree structure
   - "Here's the complete widget hierarchy in the code"

3. **Demo Counter (15 seconds)**
   - Click increment button 5-10 times
   - "Notice only the counter value updates, not the entire screen"
   - Show icon color change at 10+

4. **Demo Theme Toggle (10 seconds)**
   - Click dark mode toggle
   - "All cards and text colors update together"
   - Toggle back to light

5. **Demo Color Picker (15 seconds)**
   - Click through 3-4 colors
   - "AppBar, buttons, and icons all update instantly"
   - "This shows state affecting multiple widgets"

6. **Demo Widget Visibility (10 seconds)**
   - Toggle extra widget switch
   - "Widget animates into the tree dynamically"
   - Toggle off to show removal

7. **Explanation (20 seconds)**
   - "Flutter's reactive model means when state changes..."
   - "...only affected widgets rebuild, not everything"
   - "This keeps the UI fast and efficient"

8. **Conclusion (5 seconds)**
   - "Thanks for watching!"
   - Show final combined state

### Recording Tools:
- **Windows:** Use Xbox Game Bar (Win + G) or OBS Studio
- **Screen Recording:** Record at 1080p, 30fps minimum
- **Audio:** Use clear microphone, no background noise

### Upload:
- Upload to **Google Drive** (set to "Anyone with the link" + Edit access)
- Or upload to **YouTube** (unlisted)
- Or use **Loom** (free for recordings)

---

## ✅ Checklist

Before submitting:

- [ ] All 6 screenshots captured
- [ ] Screenshots saved in `screenshots/` folder
- [ ] Video recorded (1-2 minutes)
- [ ] Video uploaded with public link
- [ ] Link added to PR description
- [ ] README updated with screenshots
- [ ] WIDGET_TREE_ASSIGNMENT.md reviewed

---

## 💡 Tips

### For Screenshots:
- Use **Windows + Shift + S** for Windows Snipping Tool
- Capture full browser window
- Ensure all text is readable
- No personal information visible

### For Video:
- Practice the demo flow first
- Speak clearly and at moderate pace
- Show code and running app
- Explain what's happening, not just what you're clicking
- Keep it concise (1-2 min max)

### For Documentation:
- Add screenshots to README using markdown:
  ```markdown
  ![Initial State](screenshots/01_initial_state.png)
  ```
- Explain what each screenshot demonstrates
- Link to video in PR description

---

## 🎬 Example Video Link Format

In your PR description, add:

```markdown
## 📹 Demo Video

🔗 **Watch the Demo:** [Click here to view](https://your-video-link)

**Video Contents:**
- Widget tree hierarchy explanation
- Live demonstration of 4 interactive features
- State changes and reactive updates
- Performance benefits discussion
```

---

Good luck with your screenshots and video! 🚀
