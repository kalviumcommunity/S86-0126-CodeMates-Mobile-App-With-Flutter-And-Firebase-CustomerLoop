# Responsive Layout Widget Architecture

## Detailed Widget Hierarchy

```
ResponsiveLayout (StatelessWidget)
│
└── Scaffold
    ├── appBar: AppBar
    │   └── title: Text("Responsive Layout Demo")
    │
    └── body: SingleChildScrollView
        └── Container (padding: 16, color: Colors.grey[100])
            └── Column
                ├── [1] Header Section Container
                │   ├── width: double.infinity
                │   ├── height: isLandscape ? 100 : 150
                │   ├── decoration: BoxDecoration(borderRadius: 12, shadow)
                │   └── child: Center
                │       └── Column
                │           ├── Text("Header Section")
                │           └── Text("Width: XXXpx")
                │
                ├── [2] SizedBox(height: 16)
                │
                ├── [3] Content Section (Conditional)
                │   │
                │   ├── IF screenWidth > 600 → _buildWideLayout()
                │   │   └── Row
                │   │       ├── Expanded → Container (amber)
                │   │       │   └── Column (dashboard icon + text)
                │   │       ├── SizedBox(width: 16)
                │   │       └── Expanded → Container (green)
                │   │           └── Column (info icon + text)
                │   │
                │   └── ELSE → _buildNarrowLayout()
                │       └── Column
                │           ├── Container (amber, top panel)
                │           │   └── Column (icon + text)
                │           ├── SizedBox(height: 16)
                │           └── Container (green, bottom panel)
                │               └── Column (icon + text)
                │
                ├── [4] SizedBox(height: 16)
                │
                ├── [5] Stats Row Container
                │   └── Row(mainAxisAlignment: spaceEvenly)
                │       ├── _buildStatCard("Users", "1,234", Colors.blue)
                │       │   └── Column
                │       │       ├── Container(icon)
                │       │       ├── Text("1,234")
                │       │       └── Text("Users")
                │       │
                │       ├── _buildStatCard("Points", "5,678", Colors.green)
                │       │   └── [same structure]
                │       │
                │       └── _buildStatCard("Rewards", "42", Colors.orange)
                │           └── [same structure]
                │
                ├── [6] SizedBox(height: 16)
                │
                └── [7] Footer Section Container
                    ├── width: double.infinity
                    ├── color: Colors.blueGrey
                    └── child: Center
                        └── Text("Responsive layout adapts...")
```

## Component Breakdown

### 1. Header Section

**Purpose**: Demonstrate full-width Container with adaptive height

```dart
Container(
  width: double.infinity,          // Takes full available width
  height: isLandscape ? 100 : 150, // Shorter in landscape
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.lightBlueAccent,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [...],              // Add depth
  ),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Header Section',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text('Width: ${screenWidth.toStringAsFixed(0)}px'),
      ],
    ),
  ),
)
```

**Key Concepts**:
- `width: double.infinity` - Responsive full width
- `height` - Adaptive based on orientation
- `BoxDecoration` - Styling with rounded corners
- `Center` - Centering content

---

### 2. Wide Layout (Tablets/Landscape - screenWidth > 600)

**Purpose**: Display two panels side-by-side with equal width

```dart
Widget _buildWideLayout(double screenWidth, bool isLandscape) {
  return Row(
    children: [
      // LEFT PANEL
      Expanded(
        child: Container(
          height: isLandscape ? 200 : 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dashboard,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Left Panel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text('Width: ${(screenWidth / 2 - 16).toStringAsFixed(0)}px'),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      // RIGHT PANEL (same structure as left)
      Expanded(
        child: Container(
          height: isLandscape ? 200 : 300,
          // ... same decoration style
          child: Column(...),
        ),
      ),
    ],
  );
}
```

**Key Concepts**:
- `Row` - Horizontal layout
- `Expanded` - Equal width distribution
- `SizedBox(width: 16)` - Spacing between panels
- Dynamic width calculation: `(screenWidth / 2 - 16)`

**Visual Layout**:
```
┌─────────────────────────────────┐
│  Left Panel  │ Spacing │ Right  │
│  (Expanded)  │   16px  │ Panel  │
│              │         │(Expanded)
└─────────────────────────────────┘
  ← screenWidth / 2 →  ← screenWidth / 2 →
```

---

### 3. Narrow Layout (Phones - screenWidth ≤ 600)

**Purpose**: Stack panels vertically with full width each

```dart
Widget _buildNarrowLayout() {
  return Column(
    children: [
      // TOP PANEL
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(...)],
        ),
        child: Column(
          children: [
            const Icon(Icons.dashboard, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'Top Panel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Stacked vertically on small screens',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // BOTTOM PANEL (same structure as top)
      Container(
        width: double.infinity,
        // ... same decoration
        child: Column(...),
      ),
    ],
  );
}
```

**Key Concepts**:
- `Column` - Vertical layout
- `width: double.infinity` - Full width panels
- `SizedBox(height: 16)` - Vertical spacing
- Each panel takes full width

**Visual Layout**:
```
┌─────────────────────────┐
│                         │
│    Top Panel (Amber)    │
│  width: double.infinity │
│                         │
├─────────────────────────┤
│    Spacing 16px         │
├─────────────────────────┤
│                         │
│  Bottom Panel (Green)   │
│  width: double.infinity │
│                         │
└─────────────────────────┘
```

---

### 4. Stats Card Row

**Purpose**: Display three key metrics horizontally

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildStatCard('Users', '1,234', Colors.blue),
    _buildStatCard('Points', '5,678', Colors.green),
    _buildStatCard('Rewards', '42', Colors.orange),
  ],
)

Widget _buildStatCard(String label, String value, Color color) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),      // Light background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.trending_up,
          color: color,
          size: 28,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}
```

**Key Concepts**:
- `Row(mainAxisAlignment: spaceEvenly)` - Equal spacing
- `color.withOpacity(0.2)` - Transparent tint
- Vertical layout within each card
- Consistent styling

**Visual Layout**:
```
┌─────────────────────────────────────┐
│ ┌─────┐ ┌─────────┐ ┌──────────┐  │
│ │ 📈  │ │   📈    │ │    📈    │  │
│ │1234 │ │  5678   │ │    42    │  │
│ │Users│ │ Points  │ │ Rewards  │  │
│ └─────┘ └─────────┘ └──────────┘  │
└─────────────────────────────────────┘
← spaceEvenly spacing between →
```

---

## Responsive Behavior

### MediaQuery Usage

```dart
@override
Widget build(BuildContext context) {
  // Query device metrics
  final size = MediaQuery.of(context).size;
  final screenWidth = size.width;
  final screenHeight = size.height;
  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  
  debugPrint('📱 Screen: ${screenWidth}x${screenHeight}, Landscape: $isLandscape');
  
  // Decision logic
  final useWideLayout = screenWidth > 600;
  
  return Scaffold(
    // ... build UI based on useWideLayout
  );
}
```

### Breakpoint Decision Flow

```
                   ┌─────────────────────┐
                   │  Build Method       │
                   │  (Stateless Widget) │
                   └──────────┬──────────┘
                              │
                   ┌──────────▼──────────┐
                   │  Get MediaQuery     │
                   │  screenWidth        │
                   │  screenHeight       │
                   │  isLandscape        │
                   └──────────┬──────────┘
                              │
                   ┌──────────▼──────────┐
                   │  Decision: Is       │
                   │  screenWidth > 600? │
                   └──────┬──────────┬───┘
                          │          │
                    YES   │          │   NO
                          │          │
         ┌────────────────▼──┐  ┌───▼─────────────────┐
         │ _buildWideLayout()│  │ _buildNarrowLayout()│
         │                  │  │                     │
         │ • Row with 2     │  │ • Column with 2     │
         │   Expanded       │  │   containers        │
         │ • Side-by-side   │  │ • Vertical stack    │
         │ • Tablets/       │  │ • Phones/           │
         │   Landscape      │  │   Portrait          │
         └──────────────────┘  └─────────────────────┘
                   │                      │
                   └──────────┬───────────┘
                              │
                   ┌──────────▼──────────┐
                   │  Return Widget      │
                   │  (Rendered UI)      │
                   └─────────────────────┘
```

## Sizing Strategy

### Width Management

| Context | Width Value | Behavior |
|---------|------------|----------|
| Outer Container | `double.infinity` | Fills parent width |
| Row Children | `Expanded` | Shares width equally |
| Panel Width (Wide) | `screenWidth / 2 - spacing` | Half screen minus gap |
| Panel Width (Narrow) | `double.infinity` | Full width |

### Height Management

| Context | Height Value | Behavior |
|---------|------------|----------|
| Header | `isLandscape ? 100 : 150` | Adaptive |
| Wide Panels | `isLandscape ? 200 : 300` | Adaptive |
| Narrow Panels | Implicit | Wraps content |
| Stats | Implicit | Wraps content |

## Color Scheme

```
Header:  Colors.lightBlueAccent  (Light Blue)
Left:    Colors.amber             (Orange/Amber)
Right:   Colors.greenAccent       (Green)
Stats:   Colors.blue/green/orange (Multi-colored)
Footer:  Colors.blueGrey          (Dark Blue-Gray)
BG:      Colors.grey[100]         (Light Gray)
```

## Spacing Convention

```dart
const EdgeInsets.all(16)        // Standard padding
const SizedBox(width: 16)       // Horizontal gaps
const SizedBox(height: 16)      // Vertical gaps
const SizedBox(height: 12)      // Internal spacing
const SizedBox(height: 8)       // Tight spacing
const SizedBox(height: 4)       // Minimal spacing
```

## Performance Optimization

### Key Optimizations

1. **Stateless Widget**
   ```dart
   class ResponsiveLayout extends StatelessWidget {
     // No state = efficient rebuilds
   }
   ```

2. **Const Constructors**
   ```dart
   const Text('Header Section')  // Reused across rebuilds
   const SizedBox(height: 16)    // Const instances
   ```

3. **Helper Methods**
   ```dart
   Widget _buildStatCard(...)    // Extracted widget
   Widget _buildWideLayout(...)  // Separated concerns
   ```

4. **Conditional Building**
   ```dart
   // Only builds necessary widgets
   screenWidth > 600
       ? _buildWideLayout(...)
       : _buildNarrowLayout()
   ```

## Test Cases

### Visual Test Matrix

```
Screen Size | Orientation | Layout Type | Status
────────────┼─────────────┼─────────────┼─────────
360px       | Portrait    | Narrow      | ✓ Tested
390px       | Portrait    | Narrow      | ✓ Tested
412px       | Portrait    | Narrow      | ✓ Tested
600px       | Both        | Wide        | ✓ Threshold
800px       | Portrait    | Wide        | ✓ Tested
800px       | Landscape   | Wide        | ✓ Tested
1024px      | Portrait    | Wide        | ✓ Tested
1366px      | Landscape   | Wide        | ✓ Tested
```

### Checklist

- [x] Header displays properly
- [x] Layout switches at 600px breakpoint
- [x] Panels have equal width (wide layout)
- [x] Panels stack vertically (narrow layout)
- [x] Stats row displays 3 items
- [x] Footer spans full width
- [x] No overflow on small screens
- [x] No wasted space on large screens
- [x] Smooth orientation transitions
- [x] Debug values display correctly

## Summary

The ResponsiveLayout is a comprehensive example of:
1. **Layout composition** - Combining Container, Row, Column
2. **Responsive design** - Using MediaQuery for breakpoints
3. **Adaptive sizing** - Height and width based on context
4. **Visual hierarchy** - Clear sections with proper spacing
5. **Code organization** - Helper methods for reusable widgets
6. **Performance** - Efficient, const widgets and conditional building

This widget serves as a template for building responsive Flutter applications!
