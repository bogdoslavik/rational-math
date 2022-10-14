// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RationalMath.sol";

contract RationalMathTest is Test {
    using RationalMath for Rational;

    function setUp() public {
    }

    function testFromFraction(uint n, uint d) public {
        if (d == 0) d = 1;
        Rational memory r = RationalMath.from(n, d);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testFromFractionDivByZero(uint n) public {
        uint d = 0;
        vm.expectRevert(ZeroDenominator.selector);
        Rational memory r = RationalMath.from(n, d);
        assertEq(r.numerator, n);
    }

    function testFromUint(uint x) public {
        Rational memory r = RationalMath.from(x);
        assertEq(r.numerator, x);
        assertEq(r.denominator, 1);
    }

    function testCommonDivisor(uint a, uint b) public {
        uint d = RationalMath.commonDivisor(a, b);
        assertEq(a % d, 0);
        assertEq(b % d, 0);
    }

    function testCommonDivisor_0_1() public {
        uint d = RationalMath.commonDivisor(0, 1);
        assertEq(d, 1);
    }

    function testCommonDivisor_1_1() public {
        uint d = RationalMath.commonDivisor(1, 1);
        assertEq(d, 1);
    }

    function testCommonDivisor_2_4() public {
        uint d = RationalMath.commonDivisor(2, 4);
        assertEq(d, 2);
    }

    function testCommonDivisor_140_96() public {
        uint d = RationalMath.commonDivisor(140, 96);
        assertEq(d, 4);
    }

    function testCommonDivisor_prime() public {
        uint a = 19999897;
        uint b = 1002299;
        uint d = RationalMath.commonDivisor(a, b);
        assertEq(d, 1);
    }

    function testCommonDivisor_primeX(uint128 c) public {
        if (c == 0) c = 1;
        uint a = 19995023;
        uint b = 20999941;
        uint d = RationalMath.commonDivisor(a*c, b*c);
        assertEq(d, c);
    }

    //TODO add, sub, mul, div
}
