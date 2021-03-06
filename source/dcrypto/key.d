﻿module dcrypto.key;

import std.random;
import std.string;

import deimos.openssl.evp;

import dcrypto.dcrypto;

/// Basic struct for for storing a key. Includes a key, an iv and a salt.
struct Key {
	ubyte[] key, iv, salt;

	/// Allocates memory for the requested key lengths. By default they are set to the maximum values per the openssl library.
	void setSize(int keyLength = EVP_MAX_KEY_LENGTH, int ivLength = EVP_MAX_IV_LENGTH) {
		key = new ubyte[](keyLength);
		iv = new ubyte[](ivLength);
	}

	/// Creates a random salt of the specified size.
	ref Key randomizeSalt(size_t size = 8) {
		salt = new ubyte[](size);
		fillRandom!ubyte(salt);
		return this;
	}

	/// Creates a random key and iv of the specified size
	ref Key randomize(int keyLength = EVP_MAX_KEY_LENGTH, int ivLength = EVP_MAX_IV_LENGTH) {
		setSize(keyLength, ivLength);
		fillRandom!ubyte(key);
		fillRandom!ubyte(iv);
		return this;
	}
	
}

/// Build and return a key based on secret data with a random salt generated
Key keyFromSecret(string data, int rounds = 200, int keyLength = EVP_MAX_KEY_LENGTH, int ivLength = EVP_MAX_IV_LENGTH) {
	Key returnKey;

	returnKey.randomizeSalt();
	returnKey.setSize(keyLength, ivLength);

	auto d = representation(data);
	EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha256(), returnKey.salt.ptr, d.ptr, returnKey.key.sizeof, rounds, returnKey.key.ptr, returnKey.iv.ptr);

	return returnKey;
}

/// Build and return a key based on secret data using the specified salt
Key keyFromSecret(string data, string salt, int rounds = 200, int keyLength = EVP_MAX_KEY_LENGTH, int ivLength = EVP_MAX_IV_LENGTH) {
	Key returnKey;

	returnKey.salt = representation(salt).dup;
	returnKey.setSize(keyLength, ivLength);

	auto d = representation(data);
	EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha256(), returnKey.salt.ptr, d.ptr, returnKey.key.sizeof, rounds, returnKey.key.ptr, returnKey.iv.ptr);
	
	return returnKey;
}
