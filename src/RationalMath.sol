// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Rational {
    // TODO bool positive;
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

    function from(uint numerator) internal pure returns (Rational memory result) {
        result.numerator = numerator;
        result.denominator = 1;
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

    function reduce(Rational memory r) internal pure returns (Rational memory result) {
        if (r.numerator == 0) {
            result.numerator = 0;
            result.denominator = 1;
        }
        uint divisor = commonDivisor(r.numerator, r.denominator);
        result.numerator = r.numerator / divisor;
        result.denominator = r.denominator / divisor;
    }

    function commonDivisor(uint a, uint b) internal pure returns (uint small) {
        uint large;
        (large, small) = a > b ? (a, b) : (b, a);
        if (small == 0) return 1;

        uint modulo = large % small;

        while (modulo != 0) {
            large = small;
            small = modulo;
            modulo = large % small;
        }
    }






    }
