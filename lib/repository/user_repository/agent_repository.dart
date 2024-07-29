import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import '../../model/property_models/commercial_property_model.dart';
import '../../model/property_models/industrial_property_model.dart';
import '../../model/property_models/land_property_model.dart';
import '../../model/property_models/property_model.dart';
import '../../model/property_models/residential_property_model.dart';
import '../../model/user_models/agent_model.dart';

class AgentRepository extends GetxController {
  static AgentRepository get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _userRepo = Get.find<UserRepository>();

  RxList<AgentModel> favoriteAgents = <AgentModel>[].obs;
  RxMap<String, bool> isFavorite = <String, bool>{}.obs;

  Rx<AgentModel?> agentModel = Rx<AgentModel?>(
      AgentModel(
          email: "",
          userType: "",
          lastName: "",
          phoneNo: "",
          password: "",
          id: "",
          firstName: "",
          address: "",
          city: "",
          country: "",
          bio: "",
        agencyName: "",
        imageUrl: "",
      )
  );

  @override
  void onInit() {
    super.onInit();
    _userRepo.currentUser.listen((user) {
      initFavoriteAgents(); // Fetch favorites when the user is available

      if (user != null && user.userType == 'agent') {
        fetchAgentDetails(user.id); // Pass the user ID to fetchAgentDetails
      }
    });
  }

  Future<void> fetchAgentDetails(String id) async {
    agentModel.value = await getAgent(id);
  }

  Future<void> initFavoriteAgents() async {
    final clientId = _userRepo.currentUser.value!;
    getFavoriteAgents(clientId.id).then((agents) {
      favoriteAgents.assignAll(agents);
      print("Favorite agents are: $favoriteAgents");
      // Set isFavorite to true for each agent that is a favorite
      for (var agent in favoriteAgents) {
        isFavorite[agent.id] = true;
      }
      update();  // This will update the UI immediately
    });
  }

  Future<AgentModel> getAgent(String agentId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('agents').doc(agentId).get();

      if (userDoc.exists) { // Check if document exists to avoid errors
        return AgentModel.fromSnapshot(userDoc); // Use the DocumentSnapshot directly
      } else {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Agent not found',
        );
      }
    } catch (e) {
      print('Error in getAgent: $e');
      rethrow; // Rethrow the exception so it can be handled further up
    }
  }

  Future<List<PropertyModel>> getAgentsProperties(String agentId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('properties')
          .where('AgentId', isEqualTo: agentId) // Assuming you have an 'agentId' field in each property document
          .get();

      final favoriteProperties = querySnapshot.docs.map((doc) {
        switch (doc['PropertyType']) {
          case 'Residential':
            return ResidentialModel.fromSnapshot(doc);
          case 'Industrial':
            return IndustrialModel.fromSnapshot(doc);
          case 'Commercial':
            return CommercialModel.fromSnapshot(doc);
          case 'Land':
            return LandModel.fromSnapshot(doc);
          default:
            throw Exception('Unknown property type');
        }
      }).toList();

      return favoriteProperties;
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  Future<void> addFavoriteAgent(String agentId) async {
    final clientId = _firebaseAuth.currentUser!.uid;
    try {
      await _firestore.collection('clients').doc(clientId).update({
        'FavoriteAgents': FieldValue.arrayUnion([agentId])
      });
      favoriteAgents.clear();
      favoriteAgents.addAll(await getFavoriteAgents(clientId));
      print("Updated favorite agents is: $favoriteAgents");
      isFavorite[agentId] = true;
      update();
    } catch (e) {
      print('Error adding favorite agent: $e');
    }
  }

  Future<void> removeFavoriteAgent(String agentId) async {
    final clientId = _firebaseAuth.currentUser!.uid;
    try {
      await _firestore.collection('clients').doc(clientId).update({
        'FavoriteAgents': FieldValue.arrayRemove([agentId])
      });
      isFavorite[agentId] = false;
      update();
    } catch (e) {
      print('Error removing favorite agent: $e');
    }
  }

  Future<void> removeAllFavoriteAgents() async {
    final clientId = _firebaseAuth.currentUser!.uid;
    try {
      // Get the current favorite agents
      DocumentSnapshot clientDoc = await _firestore.collection('clients').doc(clientId).get();
      List<dynamic> favoriteAgentIds = clientDoc['FavoriteAgents'] ?? [];

      // Remove all favorite agents
      if (favoriteAgentIds.isNotEmpty) {
        await _firestore.collection('clients').doc(clientId).update({
          'FavoriteAgents': FieldValue.arrayRemove(favoriteAgentIds)
        });

        // Clear the local favorite agents list and update isFavorite map
        favoriteAgents.clear();
        isFavorite.clear();
        update();
      }
    } catch (e) {
      print('Error removing all favorite agents: $e');
      // Optionally, rethrow the error to handle it in your UI:
      // rethrow;
    }
  }

  Future<void> updateAgentDetails(AgentModel updatedAgent) async {
    print("Updated agent Id is:  ${updatedAgent.id}");
    print("Updated agency name is:  ${updatedAgent.agencyName}");

    try {
      await _firestore.collection('agents').doc(updatedAgent.id).update({
        'FirstName': updatedAgent.firstName,
        'LastName': updatedAgent.lastName,
        'Email': updatedAgent.email,
        'PhoneNumber': updatedAgent.phoneNo,
        'UserType': updatedAgent.userType,
        'Id': updatedAgent.id,
        'Address': updatedAgent.address,
        'City': updatedAgent.city,
        'Country': updatedAgent.country,
        'Bio': updatedAgent.bio,
        'AgencyName': updatedAgent.agencyName,
        'Password': updatedAgent.password,
        'ImageUrl': updatedAgent.imageUrl,
      });

      // Update the agentModel in the repository (to keep it in sync with Firestore)
      agentModel.value = updatedAgent;
      update(); // Trigger a UI update if needed
    } catch (e) {
      print('Error updating agent details: $e');
      // Handle the error (e.g., show a snackbar to the user)
      rethrow; // Re-throw the exception for handling in the UI layer
    }
  }

  Future<List<AgentModel>> getFavoriteAgents(String clientId) async {
    List<AgentModel> favoriteAgents = [];

    try {
      DocumentSnapshot clientDoc = await _firestore.collection('clients').doc(clientId).get();
      List<String> favoriteAgentIds = List<String>.from(clientDoc['FavoriteAgents'] ?? []);

      for (String agentId in favoriteAgentIds) {
        DocumentSnapshot agentDoc = await _firestore.collection('agents').doc(agentId).get();
        favoriteAgents.add(AgentModel.fromSnapshot(agentDoc));
      }
      update();
    } catch (e) {
      print('Error getting favorite agents: $e');
    }

    return favoriteAgents;
  }
}
