import {NativeModules, NativeEventEmitter} from 'react-native';
import {
  SignPayloadRequest,
  UJETInterface,
} from './UJETInterfaces';

const {UJETModule} = NativeModules;

const eventEmitter = new NativeEventEmitter(UJETModule);

const onSignPayloadRequest = async (_: SignPayloadRequest) => {
  // Commented because the problem is not related to this module
  // The SDK never starts, so it doesnt call this function
};

export const startListening = () => {
  eventEmitter.addListener('onSignPayloadRequest', onSignPayloadRequest);
}

export const UJET = UJETModule as UJETInterface;
