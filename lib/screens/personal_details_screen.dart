import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _birthdateController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  DateTime? _selectedBirthdate;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    // Mock user data - in real app, this would come from API/database
    _firstNameController.text = 'John';
    _lastNameController.text = 'Doe';
    _emailController.text = 'john.doe@email.com';
    _phoneController.text = '+1 (555) 123-4567';
    _addressController.text = '123 Main Street, Apt 4B';
    _cityController.text = 'New York';
    _stateController.text = 'NY';
    _zipCodeController.text = '10001';
    _selectedBirthdate = DateTime(1990, 5, 15);
    _birthdateController.text = '05/15/1990';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralWhite,
      appBar: AppBar(
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: DesignTokens.neutralGrey900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            color: DesignTokens.neutralGrey900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: DesignTokens.primaryGreen,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DesignTokens.primaryGreen,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DesignTokens.neutralGrey200,
                              border: Border.all(
                                color: DesignTokens.primaryGreen,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: DesignTokens.neutralGrey600,
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: DesignTokens.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: DesignTokens.neutralWhite,
                                    size: 20,
                                  ),
                                  onPressed: _changeProfilePicture,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space32),
                    
                    // Basic Information
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: DesignTokens.space16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    
                    GestureDetector(
                      onTap: _isEditing ? _selectBirthdate : null,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _birthdateController,
                          label: 'Date of Birth',
                          icon: Icons.calendar_today_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space32),
                    
                    // Address Information
                    _buildSectionTitle('Address Information'),
                    const SizedBox(height: DesignTokens.space16),
                    
                    _buildTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      icon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            icon: Icons.map_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: _buildTextField(
                            controller: _zipCodeController,
                            label: 'ZIP Code',
                            icon: Icons.local_post_office_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space32),
                    
                    // Account Settings
                    _buildSectionTitle('Account Settings'),
                    const SizedBox(height: DesignTokens.space16),
                    
                    _buildSettingsTile(
                      icon: Icons.security_outlined,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: _changePassword,
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    
                    _buildSettingsTile(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      onTap: _deleteAccount,
                      isDestructive: true,
                    ),
                    const SizedBox(height: DesignTokens.space32),
                    
                    // Save/Cancel Buttons
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancelEditing,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DesignTokens.neutralGrey600,
                                side: const BorderSide(color: DesignTokens.neutralGrey300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: DesignTokens.space16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignTokens.primaryGreen,
                                foregroundColor: DesignTokens.neutralWhite,
                                padding: const EdgeInsets.symmetric(
                                  vertical: DesignTokens.space16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DesignTokens.neutralGrey900,
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _isEditing ? DesignTokens.primaryGreen : DesignTokens.neutralGrey400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: DesignTokens.neutralGrey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: DesignTokens.neutralGrey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: DesignTokens.primaryGreen, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: DesignTokens.neutralGrey200),
        ),
        filled: true,
        fillColor: _isEditing ? DesignTokens.neutralWhite : DesignTokens.neutralGrey50,
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: DesignTokens.neutralGrey200),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? DesignTokens.error : DesignTokens.neutralGrey600,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? DesignTokens.error : DesignTokens.neutralGrey900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: DesignTokens.neutralGrey600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? DesignTokens.error : DesignTokens.neutralGrey400,
        ),
        onTap: onTap,
      ),
    );
  }
  
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Camera functionality would be implemented here');
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Gallery functionality would be implemented here');
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Profile picture removed');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: DesignTokens.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: DesignTokens.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DesignTokens.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }
  
  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      
      _showSuccessMessage('Personal details updated successfully!');
    }
  }
  
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reload original data
  }
  
  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality would be implemented here with proper security measures.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: DesignTokens.error),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Account deletion would be processed here');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.error,
              foregroundColor: DesignTokens.neutralWhite,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}