import React, { useEffect } from 'react';
import {View, Text, TouchableOpacity} from 'react-native';
import {startListening, UJET} from '../native_modules/UJETNativeModule';
import getStyles from './styles';

UJET.initialize({
  key: '<KEY>',
  baseUrl: '<BASE_URL>',
});

const Home: React.FC = () => {
  return <HomeComponent />;
};

const HomeComponent: React.FC = () => {
  useEffect(() => {
    UJET.setLogLevel('all');
    startListening();
  }, []);

  const styles = getStyles();

  const onPressSupport = () => {
    UJET.start({
      skipSplashScreen: false,
      preferredChannel: 'chat',
    });
  };

  return (
    <View style={styles.containerView}>
      <View style={styles.section}>
        <TouchableOpacity style={styles.button} onPress={onPressSupport}>
          <Text style={styles.buttonText}>Contact Customer Support</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default Home;
