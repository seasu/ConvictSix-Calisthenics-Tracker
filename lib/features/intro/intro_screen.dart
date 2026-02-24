import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await ref.read(profileRepositoryProvider).markIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ───────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: _page < _pageCount - 1
                  ? TextButton(
                      onPressed: _skip,
                      child: const Text(
                        '跳過',
                        style: TextStyle(color: kTextTertiary, fontSize: 14),
                      ),
                    )
                  : const SizedBox(height: 40),
            ),

            // ── Pages ─────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WelcomePage(),
                  _ConceptPage(),
                  _SixMovesPage(),
                  _ProgressionPage(),
                ],
              ),
            ),

            // ── Dots ──────────────────────────────────────────────────────
            _PageDots(current: _page, total: _pageCount),
            const SizedBox(height: 24),

            // ── CTA button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _page < _pageCount - 1 ? '繼續' : '開始使用',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Page dot indicator ───────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? kPrimary : kBgSurface3,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page 0 · Welcome ────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      emoji: '💪',
      title: '歡迎使用\nConvictSix',
      body: '結合囚徒健身精髓的自重訓練追蹤工具，\n助你系統性地征服六項菁英動作。\n\n無需器材・不分場地・純粹力量',
      extra: const _HighlightRow(items: ['自由', '漸進', '菁英']),
    );
  }
}

// ─── Page 1 · Concept ────────────────────────────────────────────────────────

class _ConceptPage extends StatelessWidget {
  const _ConceptPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      emoji: '🏋️',
      title: '囚徒健身\n是什麼？',
      body: '囚徒健身（Convict Conditioning）是 Paul Wade 在獄中研發的自重力量系統，以最純粹的動作模式，透過十個漸進步驟，從入門到菁英，塑造真實的功能性力量。',
      extra: const _BulletList(items: [
        '不依賴器材，身體即是器械',
        '關節友善，強化深層穩定肌',
        '循序漸進，成果有據可查',
      ]),
    );
  }
}

// ─── Page 2 · Six moves ──────────────────────────────────────────────────────

class _SixMovesPage extends StatelessWidget {
  const _SixMovesPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      emoji: '6️⃣',
      title: '六大\n核心動作',
      body: '系統由六個根本動作構成，覆蓋全身所有主要肌群與動作模式：',
      extra: const _ExerciseGrid(),
    );
  }
}

// ─── Page 3 · Progression ────────────────────────────────────────────────────

class _ProgressionPage extends StatelessWidget {
  const _ProgressionPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      emoji: '🎯',
      title: '十式進階\n系統',
      body: '每個動作各有十個難度遞增的「式」。完成當前式的晉級標準，就能解鎖下一式。',
      extra: const _TierList(),
    );
  }
}

// ─── Shared page layout ───────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.emoji,
    required this.title,
    required this.body,
    required this.extra,
  });

  final String emoji;
  final String title;
  final String body;
  final Widget extra;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Emoji icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kTextPrimary,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Body
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              color: kTextSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          extra,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Highlight row (page 0) ───────────────────────────────────────────────────

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (label) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: kPrimary.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Bullet list (page 1) ─────────────────────────────────────────────────────

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 10),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Exercise grid (page 2) ───────────────────────────────────────────────────

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid();

  static const _exercises = [
    ('💪', '伏地挺身', '上肢推力'),
    ('🦵', '深蹲', '下肢力量'),
    ('🏋️', '引體向上', '上肢拉力'),
    ('🦶', '舉腿', '核心力量'),
    ('🌉', '橋式', '脊椎健康'),
    ('🤸', '倒立推', '肩部力量'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: _exercises
          .map((e) => _ExerciseChip(emoji: e.$1, name: e.$2, label: e.$3))
          .toList(),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({
    required this.emoji,
    required this.name,
    required this.label,
  });

  final String emoji;
  final String name;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: kTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tier list (page 3) ───────────────────────────────────────────────────────

class _TierList extends StatelessWidget {
  const _TierList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TierRow(
          color: kTierBeginner,
          label: '初學',
          range: '式 1–4',
          dots: 4,
          desc: '建立動作基礎，培養關節韌性',
        ),
        const SizedBox(height: 10),
        _TierRow(
          color: kTierMid,
          label: '中級',
          range: '式 5–7',
          dots: 3,
          desc: '強化肌力，掌握高難度變體',
        ),
        const SizedBox(height: 10),
        _TierRow(
          color: kTierAdvanced,
          label: '進階',
          range: '式 8–10',
          dots: 3,
          desc: '菁英動作，展現真實力量',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kBgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorderSubtle),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: kTextTertiary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '達到晉級標準的組數與次數，即可進入下一式',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.color,
    required this.label,
    required this.range,
    required this.dots,
    required this.desc,
  });

  final Color color;
  final String label;
  final String range;
  final int dots;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // Dots
          Row(
            children: List.generate(
              dots,
              (_) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Label + range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    range,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kTextTertiary,
                    ),
                  ),
                ],
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: kTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
