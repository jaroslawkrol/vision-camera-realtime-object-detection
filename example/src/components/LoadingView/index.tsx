import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

const LoadingView: React.FC = () => (
  <View style={[StyleSheet.absoluteFill, styles.container]}>
    <Text style={styles.text}>Loading...</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: 'black',
  },
});

export default LoadingView;
