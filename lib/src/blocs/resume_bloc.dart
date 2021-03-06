import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_resume_app/src/database/firebase.dart';
import 'package:my_resume_app/src/model/entities/course_model.dart';
import 'package:my_resume_app/src/model/entities/resume_model.dart';
import 'package:my_resume_app/src/model/entities/skill_model.dart';
import 'package:my_resume_app/src/model/validators/resume_input_validator.dart';
import 'package:rxdart/rxdart.dart';

enum ResumeState { IDLE, LOADING, SUCCESS, FAIL }

class ResumeBloc extends BlocBase with ResumeInputValidator {
  FirebaseDB firebaseDB;
  Resume resume;
  Map<String, dynamic> resumeData = Map();

  //Constrollers
  final _titleController = BehaviorSubject<String>();
  final _fullNameController = BehaviorSubject<String>();
  final _phoneController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _skillTitleController = BehaviorSubject<String>();
  final _skillDescriptionController = BehaviorSubject<String>();
  final _courseTitleController = BehaviorSubject<String>();
  final _courseDateController = BehaviorSubject<String>();
  final _courseInstituteController = BehaviorSubject<String>();
  final _resumeController = BehaviorSubject<List>();
  final _stateController = BehaviorSubject<ResumeState>();

  //Streams
  Stream<String> get outTitle => _titleController.stream;
  Stream<String> get outFullName => _fullNameController.stream;
  Stream<String> get outPhone =>
      _phoneController.stream.transform(validatePhone);
  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);
  Stream<String> get outSkillTitle =>
      _skillTitleController.stream.transform(validateTitle);
  Stream<String> get outSkillDescription => _skillDescriptionController.stream;
  Stream<String> get outCourseTitle =>
      _courseTitleController.stream.transform(validadeCourseTitle);
  Stream<String> get outCourseDate =>
      _courseDateController.stream.transform(validadeCourseDate);
  Stream<String> get outCourseInstitute => _courseInstituteController.stream;
  Stream<List> get outResumes => _resumeController.stream;
  Stream<ResumeState> get outState => _stateController.stream;

  Function(String) get changeTitle => _titleController.sink.add;
  Function(String) get changeFullName => _fullNameController.sink.add;
  Function(String) get changePhone => _phoneController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeSkillTitle => _skillTitleController.sink.add;
  Function(String) get changeSkillDescription =>
      _skillDescriptionController.sink.add;
  Function(String) get changeCourseTitle => _courseTitleController.sink.add;
  Function(String) get changeCourseDate => _courseDateController.sink.add;
  Function(String) get changeCourseInstitute =>
      _courseInstituteController.sink.add;

  List<DocumentSnapshot> _resumes = [];

  ResumeBloc() {
    firebaseDB = FirebaseDB();
    firebaseDB.loadCurrentUser();
    Future.delayed(Duration(milliseconds: 500), () {
      _addResumeListener();
    });
    _stateController.add(ResumeState.IDLE);
    resume = Resume.def();
  }

  @override
  void dispose() {
    _resumeController.close();
    _titleController.close();
    _fullNameController.close();
    _phoneController.close();
    _emailController.close();
    _skillTitleController.close();
    _skillDescriptionController.close();
    _courseTitleController.close();
    _courseDateController.close();
    _courseInstituteController.close();

    _stateController.close();
  }

  void _addResumeListener() {
    firebaseDB.firestore
        .collection('users')
        .document(firebaseDB.firebaseUser.uid)
        .collection('resumes')
        .snapshots()
        .listen((snapshot) {
      snapshot.documentChanges.forEach((change) {
        String oid = change.document.documentID;
        switch (change.type) {
          case DocumentChangeType.added:
            _resumes.add(change.document);
            break;
          case DocumentChangeType.modified:
            _resumes.removeWhere((resume) => resume.documentID == oid);
            _resumes.add(change.document);
            break;
          case DocumentChangeType.removed:
            _resumes.removeWhere((resume) => resume.documentID == oid);
            break;
        }
      });

      _resumeController.add(_resumes);
    });
  }

  void createResume(File image) async {
    _stateController.add(ResumeState.LOADING);
    String title = _titleController.value;
    String fullName = _fullNameController.value;
    String phone = _phoneController.value;
    String email = _emailController.value;
    String skillTitle = _skillTitleController.value;
    String skillDescription = _skillDescriptionController.value;
    String courseTitle = _courseTitleController.value;
    String courseDate = _courseDateController.value;
    String courseInstitute = _courseInstituteController.value;

    String URL = await _uploadImage(image);

    resume = new Resume(
        URL,
        title,
        fullName,
        phone,
        email,
        new Skill(skillTitle, skillDescription),
        new Course(courseTitle, courseDate, courseInstitute));

    resumeData = resume.toMap();

    await saveResumeOnCloud(title, resumeData);
  }

  Future<Null> saveResumeOnCloud(
      String title, Map<String, dynamic> resumeData) {
    firebaseDB.firestore
        .collection('users')
        .document(firebaseDB.firebaseUser.uid)
        .collection('resumes')
        .document(title)
        .setData(resumeData)
        .catchError((err) {
      _stateController.add(ResumeState.FAIL);
    });

    _stateController.add(ResumeState.SUCCESS);
  }

  void editData(DocumentSnapshot resumeSnapshot) async {
    String fullName = _fullNameController.value == null
        ? resumeSnapshot.data['fullName']
        : _fullNameController.value;
    String phone = _phoneController.value == null
        ? resumeSnapshot.data['phone']
        : _phoneController.value;
    String email = _emailController.value == null
        ? resumeSnapshot.data['email']
        : _emailController.value;
    String skillTitle = _skillTitleController.value == null
        ? resumeSnapshot.data['skill']['title']
        : _skillTitleController.value;
    String skillDescription = _skillDescriptionController.value == null
        ? resumeSnapshot.data['skill']['description']
        : _skillDescriptionController.value;
    String courseTitle = _courseTitleController.value == null
        ? resumeSnapshot.data['course']['title']
        : _courseTitleController.value;
    String courseDate = _courseDateController.value == null
        ? resumeSnapshot.data['course']['date']
        : _courseDateController.value;
    String courseInstitute = _courseInstituteController.value == null
        ? resumeSnapshot.data['course']['institute']
        : _courseInstituteController.value;

    resume = new Resume(
        resumeSnapshot.data['url'],
        resumeSnapshot.documentID,
        fullName,
        phone,
        email,
        new Skill(skillTitle, skillDescription),
        new Course(courseTitle, courseDate, courseInstitute));

    resumeData = resume.toMap();

    _stateController.add(ResumeState.LOADING);

    await saveResumeOnCloud(resumeSnapshot.documentID, resumeData);
  }

  void removeResume(DocumentSnapshot resume) {
    firebaseDB.firestore
        .collection('users')
        .document(firebaseDB.firebaseUser.uid)
        .collection('resumes')
        .document(resume.documentID)
        .delete();
  }

  void onChangedSearch(String search) {
    if (search.trim().isEmpty) {
      _resumeController.add(_resumes);
    } else {
      _resumeController.add(_filter(search.trim()));
    }
  }

  List<DocumentSnapshot> _filter(String search) {
    List<DocumentSnapshot> filteredResumes = List.from(_resumes);
    filteredResumes.retainWhere((document) {
      return document.data['title']
          .toString()
          .toUpperCase()
          .contains(search.toUpperCase());
    });
    return filteredResumes;
  }

  Future<String> _uploadImage(File image) async {
    StorageUploadTask upload = firebaseDB.firebaseStorage
        .ref()
        .child('images')
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(image);

    StorageTaskSnapshot taskSnapshot = await upload.onComplete;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
