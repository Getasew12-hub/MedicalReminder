import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../features/medicine/domain/medicine_provider.dart';
import '../../../features/medicine/models/medicine.dart';
import '../../../features/medicine/widgets/day_selector.dart';
import '../../../features/medicine/widgets/type_selector.dart';
import '../../../shared/widgets/gradient_button.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key, this.medicineId});

  static const routeName = '/add-medicine';

  final String? medicineId;

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(text: '120mg');
  MedicineType _type = MedicineType.capsule;
  late TimeOfDay _time;
  late List<String> _selectedDays;
  bool _didLoadMedicine = false;

  bool get _isEditing => widget.medicineId != null;

  String _todayLabel() {
    final weekday = DateTime.now().weekday;
    return Medicine.weekDays[weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.now();
    _selectedDays = [_todayLabel()];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadMedicine || !_isEditing) return;

    final medicine =
        context.read<MedicineProvider>().findById(widget.medicineId!);
    if (medicine != null) {
      _nameController.text = medicine.name;
      _dosageController.text = medicine.dosage;
      _type = medicine.type;
      _time = medicine.time;
      _selectedDays = [...medicine.days];
    }
    _didLoadMedicine = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.rose,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    final medicineProvider = context.read<MedicineProvider>();
    final medicine = Medicine(
      id: widget.medicineId ?? '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      type: _type,
      hour: _time.hour,
      minute: _time.minute,
      days: _selectedDays,
    );

    final success = _isEditing
        ? await medicineProvider.updateMedicine(medicine)
        : await medicineProvider.addMedicine(medicine);

    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            medicineProvider.errorMessage ?? 'Unable to save medicine.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding.copyWith(top: 18, bottom: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.ink,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.field,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Edit Medicine' : 'Add New Medicine',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.medication_rounded,
                        color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      Validators.required(value, 'Medicine name'),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name of Med',
                    prefixIcon: Icon(Icons.medication_liquid_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  validator: (value) => Validators.required(value, 'Dosage'),
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    hintText: '120mg',
                    prefixIcon: Icon(Icons.scale_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Type'),
                const SizedBox(height: 12),
                TypeSelector(
                  selected: _type,
                  onChanged: (type) => setState(() => _type = type),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Choose time'),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(18),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time_rounded),
                      suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    child: Text(
                      _time.format(context),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Choose days'),
                const SizedBox(height: 12),
                DaySelector(
                  selectedDays: _selectedDays,
                  onChanged: (days) => setState(() => _selectedDays = days),
                ),
                const SizedBox(height: 34),
                Consumer<MedicineProvider>(
                  builder: (context, medicineProvider, _) {
                    return GradientButton(
                      label: _isEditing ? 'Update' : 'Save',
                      icon: Icons.check_rounded,
                      isLoading: medicineProvider.isLoading,
                      onPressed: _save,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
