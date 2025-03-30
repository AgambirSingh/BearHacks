import React, { useState, useEffect } from "react";
import { AuthClient } from "@dfinity/auth-client";

const Auth = () => {
  const [authClient, setAuthClient] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [identity, setIdentity] = useState(null);

  useEffect(() => {
    const initAuth = async () => {
      const client = await AuthClient.create();
      setAuthClient(client);

      if (await client.isAuthenticated()) {
        setIdentity(client.getIdentity());
        setIsAuthenticated(true);
      }
    };

    initAuth();
  }, []);

  const login = async () => {
    if (!authClient) return;
    await authClient.login({
      identityProvider: "https://identity.ic0.app",
      onSuccess: async () => {
        setIdentity(authClient.getIdentity());
        setIsAuthenticated(true);
      },
      onError: (err) => console.error("Login failed:", err),
    });
  };

  const logout = async () => {
    if (!authClient) return;
    await authClient.logout();
    setIdentity(null);
    setIsAuthenticated(false);
  };

  return (
    <div className="auth-container">
      <h2>ICP Authentication</h2>
      {isAuthenticated ? (
        <div>
          <p> Logged in</p>
          <button onClick={logout}>Logout</button>
        </div>
      ) : (
        <div>
          <p> Not logged in</p>
          <button onClick={login}>Login with Internet Identity</button>
        </div>
      )}
    </div>
  );
};

export default Auth;
