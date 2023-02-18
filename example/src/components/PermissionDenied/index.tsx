import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

const PermissionDenied: React.FC = () => (
  <View style={[StyleSheet.absoluteFill, styles.container]}>
    <Text style={styles.text}>Permission denied</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'red',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: 'white',
  },
});

export default PermissionDenied;
