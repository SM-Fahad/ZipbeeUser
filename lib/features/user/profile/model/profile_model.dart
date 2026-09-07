// class ProfileModel {
//   final String title;
//   final String subtitle;

//   ProfileModel({required this.title, required this.subtitle});
// }

// class UserModel {
//   final String username; // Name
//   final String email;
//   final String phone;
//   final String firstName;
//   final String lastName;
//   final String dateOfBirth;

//   UserModel({
//     required this.username,
//     required this.email,
//     required this.phone,
//     required this.firstName,
//     required this.lastName,
//     required this.dateOfBirth,
//   });

//   // Factory method to create UserModel from JSON (Map<String, dynamic>)
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] ?? json;
//     return UserModel(
//       username: data['username'] ?? '',
//       email: data['email'] ?? '',
//       phone: data['phone'] ?? '',
//       firstName: data['first_name'] ?? '',
//       lastName: data['last_name'] ?? '',
//       dateOfBirth: data['date_of_birth'] ?? '',
//     );
//   }

//   // Method to convert UserModel to JSON (Map<String, dynamic>)
//   Map<String, dynamic> toJson() {
//     return {
//       'username': username,
//       'email': email,
//       'phone': phone,
//       'firstName': firstName,
//       'lastName': lastName,
//       'dob': dateOfBirth,
//     };
//   }
// }
