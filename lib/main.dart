import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KellafApp());

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.dark;
  Color accent = const Color(0xFF7C6CF2);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    mode = ThemeMode.values[prefs.getInt('themeMode') ?? 2];
    accent = Color(prefs.getInt('accent') ?? 0xFF7C6CF2);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode value) async {
    mode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', value.index);
    notifyListeners();
  }

  Future<void> setAccent(Color value) async {
    accent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent', value.toARGB32());
    notifyListeners();
  }
}

class KellafApp extends StatelessWidget {
  const KellafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ThemeController()..load(), child: Consumer<ThemeController>(builder: (_, theme, __) {
      final light = ThemeData(useMaterial3: true, brightness: Brightness.light, colorScheme: ColorScheme.fromSeed(seedColor: theme.accent, brightness: Brightness.light));
      final dark = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: theme.accent, brightness: Brightness.dark));
      return MaterialApp(title: 'Kellaf Chat', debugShowCheckedModeBanner: false, theme: light, darkTheme: dark, themeMode: theme.mode, home: const MainShell());
    }));
  }
}

class ChatItem {
  final String name, message, time, initials;
  final Color color;
  final bool unread;
  ChatItem(this.name, this.message, this.time, this.initials, this.color, {this.unread = false});
}

final demoChats = [
  ChatItem('سارا احمدی', 'فایل طراحی امروز آماده شد 📎', 'ساعت ۲۱:۴۰', 'SA', const Color(0xFFE56DA1), unread: true),
  ChatItem('گروه خانواده', 'مامان: فردا ساعت چند می‌رسیم؟', '۲۱:۱۸', 'خ', const Color(0xFF48A7F7), unread: true),
  ChatItem('علی رضایی', 'دمو فوق‌العاده بود!', '۱۸:۴۲', 'AR', const Color(0xFF8B78F6)),
  ChatItem('کانال خبری Kellaf', '۵ خبر مهم امروز را بخوانید', '۱۶:۰۵', 'K', const Color(0xFFF3A45F)),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final page = selected == 0 ? const ChatListPage() : selected == 1 ? const ContactsPage() : selected == 2 ? const CallsPage() : const SettingsPage();
    if (wide) {
      return Scaffold(body: Row(children: [
        NavigationRail(selectedIndex: selected, onDestinationSelected: (i) => setState(() => selected = i), labelType: NavigationRailLabelType.all, leading: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: KLogo(size: 38)), destinations: const [NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: Text('چت‌ها')), NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('مخاطبان')), NavigationRailDestination(icon: Icon(Icons.call_outlined), selectedIcon: Icon(Icons.call), label: Text('تماس‌ها')), NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('تنظیمات'))]),
        const VerticalDivider(width: 1),
        SizedBox(width: 360, child: page),
        const VerticalDivider(width: 1),
        Expanded(child: selected == 0 ? const ConversationPage() : Container(alignment: Alignment.center, child: const Text('یک بخش را انتخاب کنید'))),
      ]));
    }
    return Scaffold(body: page, bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (i) => setState(() => selected = i), destinations: const [NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'چت‌ها'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'مخاطبان'), NavigationDestination(icon: Icon(Icons.call_outlined), label: 'تماس‌ها'), NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'تنظیمات')]));
  }
}

class KLogo extends StatelessWidget {
  final double size;
  const KLogo({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(size * .28), gradient: LinearGradient(colors: [color, HSLColor.fromColor(color).withLightness(.72).toColor()])), alignment: Alignment.center, child: Text('K', style: TextStyle(color: Colors.white, fontSize: size * .56, fontWeight: FontWeight.w900)));
  }
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final chats = demoChats.where((c) => c.name.contains(query)).toList();
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [const KLogo(size: 42), const SizedBox(width: 12), const Expanded(child: Text('کلاف چت', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(onPressed: () {}, icon: const Icon(Icons.edit_square))])),
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: TextField(onChanged: (v) => setState(() => query = v), decoration: InputDecoration(hintText: 'جست‌وجو', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), filled: true))),
      Expanded(child: ListView.builder(itemCount: chats.length, itemBuilder: (_, i) { final c = chats[i]; return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), leading: CircleAvatar(radius: 28, backgroundColor: c.color, child: Text(c.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(c.message, maxLines: 1, overflow: TextOverflow.ellipsis), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.time, style: TextTheme.of(context).bodySmall), if (c.unread) ...[const SizedBox(height: 5), CircleAvatar(radius: 10, child: Text('2', style: TextTheme.of(context).labelSmall?.copyWith(color: Colors.white)))] ]), onTap: () { if (MediaQuery.sizeOf(context).width < 900) Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConversationPage(name: c.name))); })); }),
    ]));
  }
}

class ConversationPage extends StatefulWidget {
  final String name;
  const ConversationPage({super.key, this.name = 'سارا احمدی'});
  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final controller = TextEditingController();
  final messages = <String>['سلام! پروژهٔ جدید آماده شد؟', 'سلام 😊 بله، الان استایل‌ها را می‌فرستم.', 'فایل طراحی امروز آماده شد 📎'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(appDeBar: _appBar(context), body: Column(children: [Expanded(child: ListView.builder(reverse: false, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) => Align(alignment: i.isOdd ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: const BoxConstraints(maxWidth: 520), decoration: BoxDecoration(color: i.isOdd ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)), child: Text(messages[i])))), Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 14), child: Row(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline)), Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: 'پیام...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none), filled: true))), IconButton(onPressed: () { final text = controller.text.trim(); if (text.isNotEmpty) setState(() { messages.add(text); controller.clear(); }); }, icon: const Icon(Icons.send))]))]));
  }

  PreferredSizeWidget _appBar(BuildContext context) => AppBar(leading: Navigator.canPop(context) ? null : null, title: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(child: Text(widget.name == 'سارا احمدی' ? 'SA' : 'ک')), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.name, style: const TextStyle(fontSize: 16)), const Text('آنلاین', style: TextStyle(fontSize: 12))])]), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined)), IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined))]);
}

class ContactsPage extends StatelessWidget { const ContactsPage({super.key}); @override Widget build(BuildContext context) => SafeArea(child: ListView(children: [const ListTile(title: Text('مخاطبان', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), ...['سارا احمدی','علی رضایی','محمد حسینی'].map((name) => ListTile(leading: CircleAvatar(child: Text(name.characters.first)), title: Text(name), trailing: const Icon(Icons.message_outlined)))])); }
class CallsPage extends StatelessWidget { const CallsPage({super.key}); @override Widget build(BuildContext context) => const SafeArea(child: Center(child: Text('تماس‌های اخیر\nهنوز تماسی ثبت نشده است', textAlign: TextAlign.center))); }

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const Row(children: [KLogo(size: 56), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('حساب Kellaf', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('Online')]))]), const SizedBox(height: 24), const Text('شخصی‌سازی', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), SegmentedButton<ThemeMode>(segments: const [ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode)), ButtonSegment(value: ThemeMode.dark, label: Text('تیره'), icon: Icon(Icons.dark_mode)), ButtonSegment(value: ThemeMode.system, label: Text('سیستم'))], selected: {theme.mode}, onSelectionChanged: (v) => theme.setMode(v.first)), const SizedBox(height: 16), const Text('رنگ برنامه'), const SizedBox(height: 8), Wrap(spacing: 12, children: [const Color(0xFF7C6CF2), const Color(0xFF2FB7A5), const Color(0xFFE56DA1), const Color(0xFFEC8B3C), const Color(0xFF3688F4)].map((c) => GestureDetector(onTap: () => theme.setAccent(c), child: CircleAvatar(backgroundColor: c, radius: 20, child: theme.accent == c ? const Icon(Icons.check, color: Colors.white) : null))).toList())]));
  }
}
