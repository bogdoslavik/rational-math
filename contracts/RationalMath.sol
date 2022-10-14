// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Rational {
    // TODO bool positive;
    uint numerator;
    uint denominator;
}

library RationalMath {

    function from(Rational memory r, uint numerator, uint denominator) {
        require(denominator != 0, 'Division by zero');
        r.numerator = numerator;
        r.denominator = denominator;
    }

    function add(Rational memory r, Rational memory value) {
        r.numerator = r.numerator * value.denominator + value.numerator * r.denominator;
        r.denominator = r.denominator * value.denominator;
    }

    function sub(Rational memory r, Rational memory value) {
        r.numerator = r.numerator * value.denominator - value.numerator * r.denominator;
        r.denominator = r.denominator * value.denominator;
    }

    function mul(Rational memory r, Rational memory value) {
        r.numerator = r.numerator * value.numerator;
        r.denominator = r.denominator * value.denominator;
    }

    function div(Rational memory r, Rational memory value) {
        r.numerator = r.numerator * value.denominator;
        r.denominator = r.denominator * value.numerator;
    }

    function reduce(Rational memory r) returns (uint small){
        uint numerator = r.numerator;
        uint denominator = r.denominator;
        uint large;
        (large, small) = denominator > numerator
            ? (denominator, numerator)
            : (numerator, denominator);

        uint modulo = large % small;

        while (modulo != 0) {
            large = small;
            small = modulo;
            modulo = large % small;
        }
    }






    }
