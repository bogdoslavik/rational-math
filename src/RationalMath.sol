// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// @author bogdoslav

struct rational {
    //bool positive;
    uint numerator;
    uint denominator;
}

error ZeroDenominator();

library Rational {

    // RATIONAL FROM

    function from(uint numerator, uint denominator) internal pure returns (rational memory result) {
        if (denominator == 0) revert ZeroDenominator();
        result.numerator = numerator;
        result.denominator = denominator;
    }

    function from(uint integer) internal pure returns (rational memory result) {
        result.numerator = integer;
        result.denominator = 1;
    }

    /// @notice creates new memory variable and copies value
    function from(rational memory a) internal pure returns (rational memory result) {
        result.numerator = a.numerator;
        result.denominator = a.denominator;
    }

    function fromFixed(uint integer, uint8 decimals) internal pure returns (rational memory result) {
        result.numerator = integer;
        result.denominator = 10**decimals;
    }

    // CONSTANTS

    function zero() internal pure returns (rational memory result) {
        result.numerator = 0;
        result.denominator = 1;
    }

    function one() internal pure returns (rational memory result) {
        result.numerator = 1;
        result.denominator = 1;
    }

    // MATH

    function _add(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result.numerator = a.numerator * b.denominator + b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function _sub(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result.numerator = a.numerator * b.denominator - b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function _mul(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result.numerator = a.numerator * b.numerator;
        result.denominator = a.denominator * b.denominator;
    }

    function _div(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result.numerator = a.numerator * b.denominator;
        result.denominator = a.denominator * b.numerator;
    }

    // REDUCED MATH

    function add(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result = _add(a, b);
        reduceIt(result);
    }

    function sub(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result = _sub(a, b);
        reduceIt(result);
    }

    function mul(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result = _mul(a, b);
        reduceIt(result);
    }

    function div(rational memory a, rational memory b) internal pure returns (rational memory result) {
        result = _div(a, b);
        reduceIt(result);
    }

    // REDUCING

    function reduceIt(rational memory r) internal pure {
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

    function reduce(rational memory r) internal pure returns (rational memory result) {
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

    function _eq(rational memory a, rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator == b.numerator * a.denominator);
    }

    function _gt(rational memory a, rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator > b.numerator * a.denominator);
    }

    function _lt(rational memory a, rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator < b.numerator * a.denominator);
    }

    function _gte(rational memory a, rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator >= b.numerator * a.denominator);
    }

    function _lte(rational memory a, rational memory b) internal pure returns (bool) {
        return (a.numerator * b.denominator <= b.numerator * a.denominator);
    }

    // TO

    function toInt(rational memory r) internal pure returns (uint) {
        return r.numerator / r.denominator;
    }

    function toBase(rational memory r, uint base) internal pure returns (uint) {
        return r.numerator * base / r.denominator;
    }

    function toFixed(rational memory r, uint8 decimals) internal pure returns (uint) {
        return r.numerator * 10**decimals / r.denominator;
    }

    // DOWNGRADE

    /// @return r significant bits (for 0 returns 0)
    /// Idea got from Mikhail Vladimirov's article  from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
    function significantBits(uint x) public pure returns (uint r) {
        if (x == 0) return 0;
        r = 1;
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
