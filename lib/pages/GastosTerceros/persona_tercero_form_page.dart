import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/providers/third_party_expenses_provider.dart';

class PersonaTerceroFormPage extends StatefulWidget {
  const PersonaTerceroFormPage({super.key, this.persona});

  final PersonaTercero? persona;

  @override
  State<PersonaTerceroFormPage> createState() => _PersonaTerceroFormPageState();
}

class _PersonaTerceroFormPageState extends State<PersonaTerceroFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.persona?.nombre);
    _apellidoController = TextEditingController(text: widget.persona?.apellido);
    _emailController = TextEditingController(text: widget.persona?.email ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.persona == null ? 'Nueva persona' : 'Editar persona'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (opcional)'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<ThirdPartyExpensesProvider>();
    await provider.guardarPersona(
      id: widget.persona?.id,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }
}
