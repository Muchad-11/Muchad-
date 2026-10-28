import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

// ===== API KEYS - SHYIRAMO IZAAWE =====
const String GEMINI_API_KEY = 'YOUR_GEMINI_API_KEY';
const String ELEVENLABS_API_KEY = 'YOUR_ELEVENLABS_API_KEY';
const String ELEVENLABS_VOICE_ID = '21m00Tcm4TlvDq8ikWAM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MuchadAIApp());
}

class MuchadAIApp extends StatelessWidget {
  const MuchadAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muchad AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0F172A)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 2; // Tangirira kuri Project Creator
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(onAdLoaded: (_) => setState(() => _bannerLoaded = true), onAdFailedToLoad: (ad, _) => ad.dispose()),
    )..load();
    RewardedAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917', request: const AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => _rewardedAd = ad, onAdFailedToLoad: (_) => _rewardedAd = null));
  }

  final _pages = [
    const ChatGeminiScreen(),
    const ImageFreeScreen(),
    const ProjectCreatorScreen(), // Nshya hano!
    const VoiceElevenScreen(),
    const SafeAboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muchad AI - Project Creator + AI'), backgroundColor: const Color(0xFF1E293B),
        actions: [IconButton(icon: const Icon(Icons.card_giftcard, color: Colors.amber), onPressed: () => _rewardedAd?.show(onUserEarnedReward: (_, __) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+10 Credits!')))))]),
      body: Column(children: [
        Expanded(child: _pages[_index]),
        if (_bannerLoaded && _bannerAd != null) SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!)),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, onTap: (i) => setState(() => _index = i), backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.purpleAccent, unselectedItemColor: Colors.grey, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Images'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Voice'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}

// ===== 1. PROJECT CREATOR - NKA PROJECTMANAGER.COM =====
class Project {
  String id, name, desc;
  List<Task> tasks;
  DateTime created;
  Project({required this.id, required this.name, required this.desc, required this.tasks, required this.created});
}
class Task {
  String title, assignee;
  bool done;
  Task({required this.title, this.assignee = 'Team', this.done = false});
}

class ProjectCreatorScreen extends StatefulWidget {
  const ProjectCreatorScreen({super.key});
  @override
  State<ProjectCreatorScreen> createState() => _ProjectCreatorScreenState();
}
class _ProjectCreatorScreenState extends State<ProjectCreatorScreen> {
  List<Project> projects = [];
  final _nameC = TextEditingController();
  final _descC = TextEditingController();

  void _createProject() {
    if (_nameC.text.isEmpty) return;
    setState(() {
      projects.add(Project(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameC.text, desc: _descC.text.isEmpty ? 'No description' : _descC.text, tasks: [], created: DateTime.now()));
      _nameC.clear(); _descC.clear();
    });
    Navigator.pop(context);
  }

  void _showCreateDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Create any project quickly and easily'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameC, decoration: const InputDecoration(hintText: 'Project name - ex: Muchad App Launch', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: _descC, decoration: const InputDecoration(hintText: 'Description', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        const Row(children: [Icon(Icons.check, color: Colors.green, size: 16), SizedBox(width: 6), Text('Organize projects, tasks and teams', style: TextStyle(fontSize: 11))]),
        const Row(children: [Icon(Icons.check, color: Colors.green, size: 16), SizedBox(width: 6), Text('Plan, track and report work', style: TextStyle(fontSize: 11))]),
        const Row(children: [Icon(Icons.check, color: Colors.green, size: 16), SizedBox(width: 6), Text('No limit to how many projects', style: TextStyle(fontSize: 11))]),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CFF00)), onPressed: _createProject, child: const Text('Start free trial', style: TextStyle(color: Colors.black)))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: projects.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.folder_copy, size: 80, color: Colors.purpleAccent),
              const SizedBox(height: 16),
              const Text('Project creator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Create any project quickly and easily', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('Project maker without hassles\nPlan, track and report • Manage teams and attach files • Import your task list', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CFF00), foregroundColor: Colors.black, minimumSize: const Size(200, 48)), onPressed: _showCreateDialog, child: const Text('Create Project')),
            ])))
          : ListView.builder(padding: const EdgeInsets.all(12), itemCount: projects.length, itemBuilder: (_, i) {
              final p = projects[i];
              final done = p.tasks.where((t) => t.done).length;
              return Card(color: const Color(0xFF1E293B), child: ExpansionTile(
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.tasks.length} tasks • $done done • ${p.created.day}/${p.created.month}'),
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(p.desc, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                  ...p.tasks.map((t) => CheckboxListTile(value: t.done, onChanged: (v) => setState(() => t.done = v!), title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null)), subtitle: Text('Assignee: ${t.assignee}'))),
                  Row(children: [
                    TextButton.icon(icon: const Icon(Icons.add_task), label: const Text('Add Task'), onPressed: () {
                      final tc = TextEditingController();
                      showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF1E293B), title: const Text('New Task'), content: TextField(controller: tc, decoration: const InputDecoration(hintText: 'Task name')), actions: [TextButton(onPressed: () { if (tc.text.isNotEmpty) setState(() => p.tasks.add(Task(title: tc.text))); Navigator.pop(context); }, child: const Text('Add'))]));
                    }),
                    TextButton.icon(icon: const Icon(Icons.delete, color: Colors.red), label: const Text('Delete', style: TextStyle(color: Colors.red)), onPressed: () => setState(() => projects.removeAt(i))),
                  ]),
                ],
              ));
            }),
      floatingActionButton: projects.isNotEmpty ? FloatingActionButton(backgroundColor: Colors.purple, onPressed: _showCreateDialog, child: const Icon(Icons.add)) : null,
    );
  }
}

// ===== 2. CHAT + GEMINI =====
class ChatGeminiScreen extends StatefulWidget { const ChatGeminiScreen({super.key}); @override State<ChatGeminiScreen> createState() => _ChatGeminiScreenState(); }
class _ChatGeminiScreenState extends State<ChatGeminiScreen> {
  final _c = TextEditingController(); final List<Map<String,String>> _msgs = [{"role":"ai","text":"Muraho! Ndi Muchad AI + Gemini. Baza!"}]; bool _loading=false;
  Future<void> _ask() async {
    if(_c.text.trim().isEmpty) return; if(GEMINI_API_KEY=='YOUR_GEMINI_API_KEY'){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shyiramo GEMINI_API_KEY!'))); return;}
    final q=_c.text; _c.clear(); setState((){_msgs.add({"role":"user","text":q}); _loading=true;});
    try{final res=await http.post(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY'), headers:{'Content-Type':'application/json'}, body:jsonEncode({"contents":[{"parts":[{"text":q}]}]})); final data=jsonDecode(res.body); final ans=data['candidates']?[0]?['content']?['parts']?[0]?['text']??'Error'; setState(()=>_msgs.add({"role":"ai","text":ans}));}catch(e){setState(()=>_msgs.add({"role":"ai","text":"Error: $e"}));} setState(()=>_loading=false);
  }
  @override Widget build(BuildContext context){return Column(children:[Expanded(child:ListView.builder(padding:const EdgeInsets.all(12), itemCount:_msgs.length, itemBuilder:(_,i){final m=_msgs[i]; final isAI=m["role"]=="ai"; return Align(alignment:isAI?Alignment.centerLeft:Alignment.centerRight, child:Container(margin:const EdgeInsets.symmetric(vertical:4), padding:const EdgeInsets.all(12), decoration:BoxDecoration(color:isAI?const Color(0xFF334155):Colors.purple, borderRadius:BorderRadius.circular(12)), child:Text(m["text"]!)));})), if(_loading) const LinearProgressIndicator(), Padding(padding:const EdgeInsets.all(8), child:Row(children:[Expanded(child:TextField(controller:_c, onSubmitted:(_)=>_ask(), decoration:InputDecoration(hintText:'Baza Gemini...', filled:true, fillColor:const Color(0xFF1E293B), border:OutlineInputBorder(borderRadius:BorderRadius.circular(24), borderSide:BorderSide.none)))), const SizedBox(width:8), CircleAvatar(backgroundColor:Colors.purple, child:IconButton(icon:const Icon(Icons.send), onPressed:_ask))]))]);}
}

// ===== 3. IMAGE FREE =====
class ImageFreeScreen extends StatefulWidget { const ImageFreeScreen({super.key}); @override State<ImageFreeScreen> createState()=>_ImageFreeScreenState();}
class _ImageFreeScreenState extends State<ImageFreeScreen> { final _p=TextEditingController(); String? _url; bool _loading=false; void _gen(){if(_p.text.isEmpty)return; setState((){_loading=true; _url='https://image.pollinations.ai/prompt/${Uri.encodeComponent(_p.text)}?nologo=true&width=1024&height=1024&seed=${DateTime.now().millisecondsSinceEpoch}';}); Future.delayed(const Duration(seconds:1), ()=>setState(()=>_loading=false));} @override Widget build(BuildContext context){return Padding(padding:const EdgeInsets.all(16), child:Column(children:[TextField(controller:_p, decoration:InputDecoration(hintText:'Kigali futuristic...', filled:true, fillColor:const Color(0xFF1E293B), border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))) , const SizedBox(height:12), ElevatedButton.icon(style:ElevatedButton.styleFrom(backgroundColor:Colors.purple, minimumSize:const Size(double.infinity,48)), onPressed:_gen, icon:const Icon(Icons.auto_awesome), label:const Text('Kora Ifoto FREE')), const SizedBox(height:20), Expanded(child:_loading?const Center(child:CircularProgressIndicator()):_url==null?const Center(child:Icon(Icons.image,size:80,color:Colors.grey)):ClipRRect(borderRadius:BorderRadius.circular(12), child:Image.network(_url!, fit:BoxFit.contain)))]));}}

// ===== 4. VOICE ELEVEN =====
class VoiceElevenScreen extends StatefulWidget { const VoiceElevenScreen({super.key}); @override State<VoiceElevenScreen> createState()=>_VoiceElevenScreenState();}
class _VoiceElevenScreenState extends State<VoiceElevenScreen> { final _t=TextEditingController(text:"Muraho, ndi Muchad AI Project Creator!"); final _player=AudioPlayer(); bool _loading=false;
Future<void> _speak() async { if(ELEVENLABS_API_KEY=='YOUR_ELEVENLABS_API_KEY'){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Shyiramo ELEVENLABS_API_KEY!'))); return;} setState(()=>_loading=true); try{final res=await http.post(Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$ELEVENLABS_VOICE_ID'), headers:{'xi-api-key':ELEVENLABS_API_KEY,'Content-Type':'application/json'}, body:jsonEncode({"text":_t.text,"model_id":"eleven_multilingual_v2"})); if(res.statusCode==200){final dir=await getTemporaryDirectory(); final file=File('${dir.path}/voice.mp3'); await file.writeAsBytes(res.bodyBytes); await _player.play(DeviceFileSource(file.path));} else{ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Error ${res.statusCode}')));} }catch(e){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Error $e')));} setState(()=>_loading=false);}
@override Widget build(BuildContext context){return Padding(padding:const EdgeInsets.all(16), child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[const Icon(Icons.record_voice_over,size:80,color:Colors.purpleAccent), const SizedBox(height:16), TextField(controller:_t,maxLines:3,decoration:InputDecoration(hintText:'Andika...',filled:true,fillColor:const Color(0xFF1E293B),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))) , const SizedBox(height:16), ElevatedButton.icon(style:ElevatedButton.styleFrom(backgroundColor:Colors.purple,minimumSize:const Size(double.infinity,48)), onPressed:_loading?null:_speak, icon:_loading?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.play_arrow), label:Text(_loading?'Irakora...':'Kora Ijwi - ElevenLabs'))]));}}

// ===== 5. ABOUT ANONYMOUS =====
class SafeAboutScreen extends StatelessWidget { const SafeAboutScreen({super.key}); @override Widget build(BuildContext context){return ListView(padding:const EdgeInsets.all(20), children:const[Center(child:Icon(Icons.smart_toy,size:70,color:Colors.purple)), SizedBox(height:12), Center(child:Text('Muchad AI + Project Creator',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))), Center(child:Text('Project creator • Organize, Plan, Track • No limit\nChat-Gemini • Images-Free • Voice-Eleven • AdMob',style:TextStyle(color:Colors.purpleAccent,fontSize:11),textAlign:TextAlign.center)), SizedBox(height:20), Card(color:Color(0xFF1E293B),child:ListTile(leading:Icon(Icons.folder_special,color:Colors.green),title:Text('Project Creator'),subtitle:Text('Nka ProjectManager.com - Ikora 100%'))), Card(color:Color(0xFF1E293B),child:ListTile(leading:Icon(Icons.shield),title:Text('Privacy'),subtitle:Text('No personal data collected - Anonymous'))), SizedBox(height:20), Center(child:Text('© 2026 Muchad AI - Anonymous - v1.0.0',style:TextStyle(color:Colors.grey,fontSize:11))) ]);}}
