// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// @author bogdoslav
// TODO add doc comments

struct Rational {
    // TODO add sign
    //bool positive;
    uint numerator;
    uint denominator;
}

error ZeroDenominator();

library RationalMath {

    function from(uint numerator, uint denominator) internal pure returns (Rational memory result) {
        if (denominator == 0) revert ZeroDenominator();
        result.numerator = numerator;
        result.denominator = denominator;
    }

    function fromFixed(uint integer, uint8 decimals) internal pure returns (Rational memory result) {
        if (decimals == 0) revert ZeroDenominator();
        result.numerator = integer;
        result.denominator = 10**decimals;
    }

    function from(uint integer) internal pure returns (Rational memory result) {
        result.numerator = integer;
        result.denominator = 1;
    }

    function from(Rational memory a) internal pure returns (Rational memory result) {
        result.numerator = a.numerator;
        result.denominator = a.denominator;
    }

    function add(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator + b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function sub(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator - b.numerator * a.denominator;
        result.denominator = a.denominator * b.denominator;
    }

    function mul(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.numerator;
        result.denominator = a.denominator * b.denominator;
    }

    function div(Rational memory a, Rational memory b) internal pure returns (Rational memory result) {
        result.numerator = a.numerator * b.denominator;
        result.denominator = a.denominator * b.numerator;
    }

    function reduceIt(Rational memory r) internal pure {
        if (r.numerator == 0) {
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

}
