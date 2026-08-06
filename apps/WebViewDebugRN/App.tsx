import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {SafeAreaProvider} from 'react-native-safe-area-context';
import {StatusBar} from 'react-native';
import ConfigScreen from './src/screens/ConfigScreen';
import PreviewScreen from './src/screens/PreviewScreen';
import type {RootStackParamList} from './src/types';

const Stack = createNativeStackNavigator<RootStackParamList>();

const App: React.FC = () => {
  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" backgroundColor="#020617" />
      <NavigationContainer>
        <Stack.Navigator
          initialRouteName="Config"
          screenOptions={{headerShown: false}}>
          <Stack.Screen name="Config" component={ConfigScreen} />
          <Stack.Screen
            name="Preview"
            component={PreviewScreen}
            options={{gestureEnabled: false}}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
};

export default App;
