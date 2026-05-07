import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/domain/auth_provider.dart';
import '../../../features/auth/domain/user_profile_provider.dart';
import '../../../features/home/widgets/calendar_strip.dart';
import '../../../features/home/widgets/medicine_card.dart';
import '../../../features/medicine/domain/medicine_provider.dart';
import '../../../features/medicine/models/medicine.dart';
import '../../../features/medicine/screens/add_medicine_screen.dart';
import '../../../shared/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer3<MedicineProvider, AuthProvider, UserProfileProvider>(
          builder: (context, medicineProvider, authProvider,
              userProfileProvider, _) {
            final medicines = medicineProvider.medicines;

            return IndexedStack(
              index: _selectedIndex,
              children: [
                _HomeTab(
                  medicines: medicines,
                  medicineProvider: medicineProvider,
                  displayName: userProfileProvider.displayName,
                ),
                _ScheduleTab(medicines: medicines),
                _ProfileTab(
                  authProvider: authProvider,
                  userProfileProvider: userProfileProvider,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AddMedicineScreen.routeName),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Medicine'),
              foregroundColor: Colors.white,
              backgroundColor: AppColors.rose,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.roseLight,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.rose),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppColors.rose),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.rose),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.medicines,
    required this.medicineProvider,
    required this.displayName,
  });

  final List<Medicine> medicines;
  final MedicineProvider medicineProvider;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: AppConstants.screenPadding.copyWith(top: 22),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi $displayName',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep your meds on track today',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                    _NotificationButton(medicines: medicines),
                  ],
                ),
                const SizedBox(height: 28),
                const CalendarStrip(),
                const SizedBox(height: 34),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today activities',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${medicines.length} meds',
                      style: const TextStyle(
                        color: AppColors.rose,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: AppConstants.screenPadding.copyWith(bottom: 96),
          sliver: _MedicineListSliver(
            medicines: medicines,
            isLoading: medicineProvider.isLoading,
            onDone: (id) async {
              await medicineProvider.markDone(id);
              if (context.mounted) {
                _showMessage(context, 'Marked as done');
              }
            },
            onSkip: (id) async {
              await medicineProvider.markSkipped(id);
              if (context.mounted) {
                _showMessage(context, 'Skipped reminder');
              }
            },
            onDelete: (id) async {
              final confirmed = await _confirmDelete(context);
              if (!confirmed) return;
              await medicineProvider.deleteMedicine(id);
              if (context.mounted) {
                _showMessage(context, 'Medicine deleted');
              }
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.medicines});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    final upcoming = medicines.where((medicine) => !medicine.isDone).toList();

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Upcoming reminders',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                const Text(
                  'No active reminders right now.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                ...upcoming.map(
                  (medicine) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.roseLight,
                      child: Icon(medicine.type.icon, color: AppColors.rose),
                    ),
                    title: Text(medicine.name),
                    subtitle: Text(
                      '${medicine.time.format(context)} | ${medicine.days.join(', ')}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.roseLight,
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.rose,
            ),
          ),
          if (upcoming.isNotEmpty)
            Positioned(
              right: 3,
              top: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicineListSliver extends StatelessWidget {
  const _MedicineListSliver({
    required this.medicines,
    required this.isLoading,
    required this.onDone,
    required this.onSkip,
    required this.onDelete,
  });

  final List<Medicine> medicines;
  final bool isLoading;
  final ValueChanged<String> onDone;
  final ValueChanged<String> onSkip;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.rose),
        ),
      );
    }

    if (medicines.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyState());
    }

    return SliverList.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return MedicineCard(
          medicine: medicine,
          onDone: () => onDone(medicine.id),
          onSkip: () => onSkip(medicine.id),
          onEdit: () => context.push(
            '${AddMedicineScreen.routeName}/${medicine.id}',
          ),
          onDelete: () => onDelete(medicine.id),
        );
      },
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.medicines});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppConstants.screenPadding.copyWith(top: 22, bottom: 96),
      children: [
        Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'Your weekly medication plan',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        for (final day in Medicine.weekDays) ...[
          Text(
            day,
            style: const TextStyle(
              color: AppColors.rose,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ..._medicinesForDay(day).map(
            (medicine) => _ScheduleTile(medicine: medicine),
          ),
          if (_medicinesForDay(day).isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'No reminders',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<Medicine> _medicinesForDay(String day) {
    final items =
        medicines.where((medicine) => medicine.days.contains(day)).toList();
    items.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return items;
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.roseLight,
            child: Icon(medicine.type.icon, color: AppColors.rose),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${medicine.dosage} | ${medicine.type.label}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            medicine.time.format(context),
            style: const TextStyle(
              color: AppColors.rose,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.authProvider,
    required this.userProfileProvider,
  });

  final AuthProvider authProvider;
  final UserProfileProvider userProfileProvider;

  @override
  Widget build(BuildContext context) {
    final profile = userProfileProvider.profile;

    return ListView(
      padding: AppConstants.screenPadding.copyWith(top: 22, bottom: 96),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              _ProfileAvatar(
                avatarBytes: userProfileProvider.avatarBytes,
                radius: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileProvider.displayName,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? authProvider.email,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: AppColors.field,
          leading: const Icon(Icons.edit_rounded, color: AppColors.rose),
          title: const Text('Edit profile'),
          subtitle: const Text('Change name, photo, phone, and contact'),
          onTap: () => _showEditProfileSheet(
            context,
            authProvider: authProvider,
            userProfileProvider: userProfileProvider,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: AppColors.field,
          leading: const Icon(Icons.phone_outlined, color: AppColors.rose),
          title: const Text('Phone'),
          subtitle: Text(
            profile?.phone.isNotEmpty == true
                ? profile!.phone
                : 'Add phone number',
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: AppColors.field,
          leading: const Icon(Icons.health_and_safety_outlined,
              color: AppColors.rose),
          title: const Text('Emergency contact'),
          subtitle: Text(
            profile?.emergencyContact.isNotEmpty == true
                ? profile!.emergencyContact
                : 'Add emergency contact',
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: AppColors.roseLight,
          leading:
              const Icon(Icons.notifications_active, color: AppColors.rose),
          title: const Text('Test reminder sound'),
          subtitle:
              const Text('Temporary button for checking notification audio'),
          onTap: () async {
            await context.read<NotificationService>().showTestNotificationNow();
            if (context.mounted) {
              _showMessage(context, 'Test notification sent.');
            }
          },
        ),
        const SizedBox(height: 20),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: AppColors.field,
          leading: const Icon(Icons.logout_rounded, color: AppColors.rose),
          title: const Text('Logout'),
          onTap: authProvider.logout,
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarBytes,
    required this.radius,
  });

  final Uint8List? avatarBytes;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (avatarBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(avatarBytes!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.roseLight,
      child: Icon(
        Icons.person_rounded,
        color: AppColors.rose,
        size: radius,
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.authProvider,
    required this.userProfileProvider,
  });

  final AuthProvider authProvider;
  final UserProfileProvider userProfileProvider;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyController;
  final _formKey = GlobalKey<FormState>();
  String? _avatarBase64;
  bool _clearAvatar = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.userProfileProvider.profile;
    _nameController = TextEditingController(
      text: profile?.name ?? widget.authProvider.displayName,
    );
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _emergencyController = TextEditingController(
      text: profile?.emergencyContact ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarBytes = _avatarBase64 != null
        ? widget.userProfileProvider.avatarBytesFromBase64(_avatarBase64!)
        : (_clearAvatar ? null : widget.userProfileProvider.avatarBytes);

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Edit profile',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
            Row(
              children: [
                _ProfileAvatar(avatarBytes: avatarBytes, radius: 30),
                const SizedBox(width: 14),
                TextButton.icon(
                  onPressed: () async {
                    final selected =
                        await widget.userProfileProvider.pickAvatarBase64();
                    if (!mounted || selected == null) return;
                    setState(() {
                      _avatarBase64 = selected;
                      _clearAvatar = false;
                    });
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose photo'),
                ),
                if (avatarBytes != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _avatarBase64 = null;
                        _clearAvatar = true;
                      });
                    },
                    child: const Text('Remove'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Name is required'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.authProvider.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact',
                prefixIcon: Icon(Icons.health_and_safety_outlined),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final success =
                      await widget.userProfileProvider.updateProfile(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    emergencyContact: _emergencyController.text,
                    avatarBase64: _avatarBase64,
                    clearAvatar: _clearAvatar,
                  );

                  if (!mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    _showMessage(context, 'Profile updated');
                  } else {
                    _showMessage(
                      context,
                      widget.userProfileProvider.errorMessage ??
                          'Unable to update profile',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.medication_liquid_rounded,
            color: AppColors.rose,
            size: 52,
          ),
          SizedBox(height: 14),
          Text(
            'No medicines yet',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first reminder to start your schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

Future<void> _showEditProfileSheet(
  BuildContext context, {
  required AuthProvider authProvider,
  required UserProfileProvider userProfileProvider,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _EditProfileSheet(
      authProvider: authProvider,
      userProfileProvider: userProfileProvider,
    ),
  );
}

Future<bool> _confirmDelete(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Delete medicine?'),
          content: const Text('This will also cancel its reminders.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.rose),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
