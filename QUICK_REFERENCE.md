# Responsive Layout - Quick Reference Guide

## 🚀 Quick Start

### Launch App
```bash
cd customerloop
flutter run -d chrome
```

### Navigate to Responsive Layout
```dart
Navigator.pushNamed(context, '/responsive-layout');
```

### Or via Demo Menu
Navigate to `/demo-menu` and tap "Responsive Layout Demo"

---

## 📱 Core Widgets Reference

### Container
```dart
Container(
  width: double.infinity,        // Full width
  height: 150,                   // Fixed height
  padding: EdgeInsets.all(16),   // Inside spacing
  margin: EdgeInsets.all(8),     // Outside spacing
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(...)],
  ),
  child: Text('Content'),
)
```

### Row
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // H-spacing
  crossAxisAlignment: CrossAxisAlignment.center,      // V-align
  children: [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.person),
  ],
)
```

### Column
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,       // V-spacing
  crossAxisAlignment: CrossAxisAlignment.start,      // H-align
  children: [
    Text('Title'),
    SizedBox(height: 10),
    Text('Subtitle'),
  ],
)
```

### Expanded (inside Row/Column)
```dart
Row(
  children: [
    Expanded(
      child: Container(color: Colors.red),    // Takes 1/2 width
    ),
    SizedBox(width: 10),
    Expanded(
      child: Container(color: Colors.blue),   // Takes 1/2 width
    ),
  ],
)
```

---

## 📐 Responsive Logic

### Get Screen Size
```dart
double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
```

### Conditional Layout
```dart
// Phone vs Tablet layout
if (screenWidth > 600) {
  return _buildTabletLayout();
} else {
  return _buildPhoneLayout();
}
```

### Adaptive Values
```dart
height: isLandscape ? 100 : 150;
padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16);
```

---

## 🎨 Layout Patterns

### Full-Width Container
```dart
Container(
  width: double.infinity,
  height: 150,
  color: Colors.blue,
  child: Center(child: Text('Header')),
)
```

### Side-by-Side Panels
```dart
Row(
  children: [
    Expanded(child: Container(color: Colors.amber)),
    SizedBox(width: 16),
    Expanded(child: Container(color: Colors.green)),
  ],
)
```

### Vertical Stack
```dart
Column(
  children: [
    Container(color: Colors.amber),
    SizedBox(height: 16),
    Container(color: Colors.green),
  ],
)
```

### Stats Row
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _statCard('Title', 'Value'),
    _statCard('Title', 'Value'),
    _statCard('Title', 'Value'),
  ],
)
```

---

## 🧪 Testing

### Chrome DevTools
1. Press `F12` to open DevTools
2. Click device icon (mobile icon) to enable mobile view
3. Select device or use custom size
4. Test at breakpoints: 360px, 600px, 800px, 1024px

### Test Checklist
- [ ] Narrow view (<600px) stacks vertically
- [ ] Wide view (>600px) shows side-by-side
- [ ] Header is full-width
- [ ] Footer is full-width
- [ ] Stats show 3 columns
- [ ] No overflow in narrow view
- [ ] Responsive at 600px breakpoint
- [ ] Landscape mode works

---

## ✅ Implementation Checklist

- [x] Container widget used for styling
- [x] Row widget used for horizontal layout
- [x] Column widget used for vertical layout
- [x] MediaQuery for responsive values
- [x] Expanded for proportional sizing
- [x] 600px breakpoint implemented
- [x] Landscape orientation handled
- [x] Proper spacing with SizedBox
- [x] Debug output shows screen dimensions
- [x] Navigation routes added
- [x] Code properly formatted
- [x] Documentation complete

---

## 📊 Screen Size Breakpoints

```
 0-599px:  Narrow Layout (Phones)
           • Vertical stacking
           • Full-width panels
           • Single column

600px+:    Wide Layout (Tablets)
           • Side-by-side panels
           • Proportional sizing
           • Landscape support
```

---

## 🔧 Common Tasks

### Add Another Panel
```dart
Expanded(
  child: Container(
    color: Colors.cyan,
    child: Center(child: Text('New Panel')),
  ),
)
```

### Add Adaptive Padding
```dart
padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
```

### Add Spacing
```dart
SizedBox(height: 16)  // Vertical space
SizedBox(width: 16)   // Horizontal space
```

### Add Shadow
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: Offset(0, 4),
  ),
]
```

---

## 📚 File References

| File | Purpose |
|------|---------|
| [lib/screens/responsive_layout.dart](lib/screens/responsive_layout.dart) | Main widget implementation |
| [lib/screens/demo_menu_screen.dart](lib/screens/demo_menu_screen.dart) | Navigation menu |
| [lib/main.dart](lib/main.dart) | Route configuration |
| [RESPONSIVE_LAYOUT_README.md](RESPONSIVE_LAYOUT_README.md) | Full documentation |
| [TESTING_AND_SCREENSHOTS.md](TESTING_AND_SCREENSHOTS.md) | Testing guide |
| [WIDGET_ARCHITECTURE.md](WIDGET_ARCHITECTURE.md) | Architecture details |

---

## 💡 Pro Tips

1. **Use Const**
   ```dart
   const Text('Title')  // Reusable across rebuilds
   ```

2. **Extract Widgets**
   ```dart
   Widget _buildPanel() { ... }  // For reusability
   ```

3. **Use SizedBox**
   ```dart
   SizedBox(height: 16)  // More readable than Padding
   ```

4. **Test Often**
   ```bash
   flutter run -d chrome  # Easy testing
   # Press F12 for DevTools
   ```

5. **Debug Print**
   ```dart
   debugPrint('📱 Width: $screenWidth');  // Quick debugging
   ```

---

## 🎯 Key Takeaways

✅ Container = Styling + Layout
✅ Row = Horizontal layout
✅ Column = Vertical layout
✅ Expanded = Equal width/height distribution
✅ MediaQuery = Get screen dimensions
✅ SizedBox = Intentional spacing
✅ double.infinity = Responsive full width
✅ 600px = Common breakpoint

---

## 🚨 Common Mistakes to Avoid

❌ Hard-coding pixel values
❌ Forgetting MediaQuery.of(context)
❌ Not testing on different screen sizes
❌ Over-nesting containers
❌ Ignoring landscape orientation
❌ Using fixed heights when flexible needed
❌ Not using const constructors
❌ Ignoring safe areas (notches)

---

## 📖 More Resources

- Flutter Docs: https://flutter.dev/docs
- MediaQuery: https://api.flutter.dev/flutter/widgets/MediaQuery-class.html
- Container: https://api.flutter.dev/flutter/widgets/Container-class.html
- Responsive Design: https://flutter.dev/docs/development/ui/layout/responsive

---

**Happy Building! 🚀**

For detailed information, see the comprehensive documentation files in this project.
