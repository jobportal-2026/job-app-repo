import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/candidate_card_widget.dart';

class ApplicantsListScreen extends StatefulWidget {
  const ApplicantsListScreen({super.key});

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  String _selectedFilter = 'All';

  final List<CandidateModel> _candidates = [
    const CandidateModel(
      id: 'cand-1',
      name: 'Priya Sharma',
      title: 'Certified Barista & Cashier',
      rating: 4.9,
      reviewsCount: 22,
      distanceKm: 1.8,
      skills: ['Espresso Machines', 'Customer Service', 'POS Billing', 'Inventory'],
      availability: 'Weekends • Immediate',
      hourlyRate: '₹450/hr',
      experience: '2 years part-time barista experience at Starbucks and Blue Tokai',
      education: 'B.Sc Economics (Final Year), Mount Carmel College',
      about: 'Passionate specialty coffee enthusiast with over 2 years of specialty brewing and high-rush hospitality experience. Loves engaging with customers.',
      phone: '+91 98765 43210',
      email: 'priya.sharma@example.com',
    ),
    const CandidateModel(
      id: 'cand-2',
      name: 'Rahul Verma',
      title: 'Tech Event Coordinator & AV Tech',
      rating: 4.8,
      reviewsCount: 14,
      distanceKm: 3.4,
      skills: ['Stage Management', 'Live Audio/Video', 'Crowd Management', 'Registration'],
      availability: 'Flexible • Weekday Evenings & Weekends',
      hourlyRate: '₹3,000/day',
      experience: 'Coordinated 6 major university conferences and hackathons',
      education: 'B.Tech CS (3rd Year), RV College of Engineering',
      about: 'Energetic coordinator experienced with logistics, audio/visual setups, and quick problem solving under tight event schedules.',
      phone: '+91 98765 11223',
      email: 'rahul.verma@example.com',
    ),
    const CandidateModel(
      id: 'cand-3',
      name: 'Ananya Deshmukh',
      title: 'Graphic Designer & Social Media Creator',
      rating: 4.9,
      reviewsCount: 19,
      distanceKm: 2.1,
      skills: ['Canva Pro', 'Figma', 'Instagram Reels', 'Copywriting'],
      availability: 'Part-time • 15 hrs/week',
      hourlyRate: '₹600/hr',
      experience: 'Created viral promo reels for 4 college fest sponsors & 2 local cafes',
      education: 'B.Des Visual Communication, Srishti Institute',
      about: 'Creative designer specialized in bold digital posters, social media banners, and quick promotional videos that drive student engagement.',
      phone: '+91 98765 88990',
      email: 'ananya.d@example.com',
    ),
    const CandidateModel(
      id: 'cand-4',
      name: 'Karan Patel',
      title: 'Maths & Coding Tutor (High School)',
      rating: 4.7,
      reviewsCount: 9,
      distanceKm: 4.2,
      skills: ['CBSE / ICSE Maths', 'Python Basics', 'Physics', 'Doubt Solving'],
      availability: 'Evenings • Mon-Fri 5 PM to 8 PM',
      hourlyRate: '₹550/hr',
      experience: 'Taught over 35 high school students with 95%+ grade improvement',
      education: 'B.Sc Mathematics & Data Science, Christ University',
      about: 'Patient and encouraging tutor skilled at breaking down tough calculus, algebra, and programming problems into simple intuitive concepts.',
      phone: '+91 98765 33445',
      email: 'karan.patel@example.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Applicants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
            tooltip: 'Filter Candidates',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Hospitality', 'Events', 'Design', 'Tutoring'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Candidates list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _candidates.length,
              itemBuilder: (context, index) {
                final cand = _candidates[index];
                return CandidateCardWidget(
                  candidate: cand,
                  onTap: () {
                    context.push('/candidate-details', extra: cand);
                  },
                  onHire: () {
                    context.push(
                      '/employer-payment?candidateName=${Uri.encodeComponent(cand.name)}&title=${Uri.encodeComponent(cand.title)}&amount=450',
                    );
                  },
                  onChat: () {
                    context.push('/chat?name=${Uri.encodeComponent(cand.name)}&role=Candidate');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
