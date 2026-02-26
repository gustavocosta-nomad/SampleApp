import {StyleSheet} from 'react-native';

const theme = {
  PRIMARY_COLOR: '#3498DB',
  BACKGROUND_COLOR: '#222',
  TEXT_COLOR: 'white',
  STATUS_BAR_STYLE: 'light-content'
}

const getStyles = () =>
  StyleSheet.create({
    containerView: {
      justifyContent: 'center',
      padding: 16,
      flex: 1,
      backgroundColor: theme.BACKGROUND_COLOR,
    },
    button: {
      backgroundColor: theme.PRIMARY_COLOR,
      padding: 10,
      borderRadius: 5,
      marginBottom: 16,
      marginHorizontal: 16,
      alignItems: 'center',
    },
    buttonText: {
      fontWeight: 'bold',
      color: 'white',
    },
    section: {
      marginBottom: 32,
    },
  });

export default getStyles;
