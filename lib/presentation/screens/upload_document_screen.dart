import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_providers.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  final String storeId;

  const UploadDocumentScreen({super.key, required this.storeId});

  @override
  ConsumerState<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        if (_displayNameController.text.isEmpty) {
          _displayNameController.text = result.files.single.name;
        }
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await ref.read(documentsListProvider(widget.storeId).notifier).uploadDocument(
              _selectedFile!,
              displayName: _displayNameController.text,
            );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Select File'),
              ),
              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Selected: ${_selectedFile!.path.split('/').last}'),
                ),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadDocument,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
