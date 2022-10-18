// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// @author bogdoslav

struct Rational {
    //bool positive;
    uint numerator;
    uint denominator;
}

error ZeroDenominator();

library RationalMath {

    // RATIONAL FROM

    function from(uint numerator, uint denominator) internal pure returns (Rational memory result) {
        if (denominator == 0) revert ZeroDenominator();
        result.numerator = numerator;
        result.denominator = denominator;
    }

    function from(uint integer) internal pure returns (Rational memory result) {
        result.numerator = integer;
        result.denominator = 1;
    }

    /// @notice creates new memory variable and copies value
    function from(Rational memory a) internal pure returns (Rational memory result) {
        result.numerator = a.numerator;
        result.denominator = a.denominator;
    }

    function fromFixed(uint integer, uint8 decimals) internal pure returns (Rational memory result) {
        result.numerator = integer;
        result.denominator = 10**decimals;
    }

    // CONSTANTS

    function zero() internal pure returns (Rational memory result) {
        result.numerator = 0;
        result.denominator = 1;
    }

    function one() internal pure returns (Rational memory result) {
        result.numerator = 1;
        result.denominator = 1;
    }

    // UNSAFE MATH

    function _add(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator + b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function _sub(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator - b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function _mul(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.numerator;
        result.denominator = a.denominator * b.denominator;
    }

    function _div(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator;
        result.denominator = a.denominator * b.numerator;
    }

    // REDUCING

    function reduceIt(Rational memory r) internal pure {
        if (r.numerator == 0) {
            r.denominator = 1;
        } if (r.numerator == r.denominator) {
            r.numerator = 1;
            r.denominator = 1;
        } else {
            uint divisor = commonDivisor(r.numerator, r.denominator);
            r.numerator = r.numerator / divisor;
            r.denominator = r.denominator / divisor;
        }
    }

    function reduce(Rational memory r) internal pure returns (Rational memory result) {
        result.numerator = r.numerator;
        result.denominator = r.denominator;
        reduceIt(result);
    }

    function commonDivisor(uint a, uint b) internal pure returns (uint small) {
        while (a != 0 && b != 0) {
            if (a > b) {
                a = a % b;
            } else {
                b = b % a;
            }
        }
        return a + b;
    }

    // COMPARISON

    function _eq(Rational memory a, Rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator == b.numerator * a.denominator);
    }

    // TO

    function toInt(Rational memory r) internal pure returns (uint) {
        return r.numerator / r.denominator;
    }

    function toBase(Rational memory r, uint base) internal pure returns (uint) {
        return r.numerator * base / r.denominator;
    }

    function toFixed(Rational memory r, uint8 decimals) internal pure returns (uint) {
        return r.numerator * 10**decimals / r.denominator;
    }

    // DOWNGRADE

    /// @return r most significant bit (1-based). For 0 returns 0
    /// Idea got from Mikhail Vladimirov's article  from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
    function mostSignificantBit(uint x) public pure returns (uint r) {
        if (x == 0) return 0;
        r = 0;
        if (x >= 2**128) { x >>= 128; r += 128; }
        if (x >= 2**64) { x >>= 64; r += 64; }
        if (x >= 2**32) { x >>= 32; r += 32; }
        if (x >= 2**16) { x >>= 16; r += 16; }
        if (x >= 2**8) { x >>= 8; r += 8; }
        if (x >= 2**4) { x >>= 4; r += 4; }
        if (x >= 2**2) { x >>= 2; r += 2; }
        if (x >= 2**1) { x >>= 1; r += 1; }
    }
}
