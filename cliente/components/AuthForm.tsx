'use client';

import LoginForm from './LoginForm';
import RegisterForm from './RegisterForm';

interface AuthFormProps {
  mode: 'login' | 'register';
  onLoginSuccess: (usuario: { [key: string]: any }) => void;
}

export default function AuthForm({ mode, onLoginSuccess }: AuthFormProps) {
  return (
    <div>
      {mode === 'login' ? <LoginForm onLoginSuccess={onLoginSuccess} /> : <RegisterForm />}
    </div>
  );
}
