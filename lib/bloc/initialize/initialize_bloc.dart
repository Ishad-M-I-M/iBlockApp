import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../services/secure_storage_service.dart';
import '../../services/user_contract_service.dart';

part 'initialize_event.dart';
part 'initialize_state.dart';

class InitializeBloc extends Bloc<InitializeEvent, InitializeState> {
  InitializeBloc() : super(Initial()) {
    on<InitializeAppEvent>((event, emit) async{
      emit(Initial());
      await Future.delayed(const Duration(seconds: 3));

      emit(CheckingInternetConnection());
      await Future.delayed(const Duration(seconds: 3));

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        bool isPrivateKeyExist = await SecureStorageService.isKeyExist("private-key");
        bool isContractAddressExist = await SecureStorageService.isKeyExist("contract-address");
        if (isPrivateKeyExist && isContractAddressExist){
          var privateKey = await SecureStorageService.get("private-key") as String;
          var contractAddress = await SecureStorageService.get("contract-address") as String;


          var userInfo = await UserContractService().getAll(contractAddress, privateKey);
          emit(Registered(userInfo));
        }
        else{
          emit(NotRegistered());
        }
      }
      else{
        emit(NoInternetConnection());
      }

    });
  }
}
