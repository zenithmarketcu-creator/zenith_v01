// lib/src/presentation/screens/admin/admin_offers_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../blocs/admin/admin_bloc.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});
  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadOffers());
  }

  Future<void> _addOffer() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      if (mounted) {
        context.read<AdminBloc>().add(AdminAddOffer(File(picked.path)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Manage Offers'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addOffer),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOffersLoaded) {
            if (state.offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No offers yet', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Offer'),
                      onPressed: _addOffer,
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.offers.length,
              itemBuilder: (context, i) {
                final offer = state.offers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: offer.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => context.read<AdminBloc>().add(AdminDeleteOffer(offer)),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.delete, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
