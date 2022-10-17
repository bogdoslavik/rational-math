// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RationalMath.sol";
import "forge-std/console.sol";

contract RationalMathTest is Test {
    using RationalMath for Rational;

    function setUp() public {
    }

    // From

    function testFromFraction(uint n, uint d) public {
        if (d == 0) d = 1;
        Rational memory r = RationalMath.from(n, d);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testFromFractionDivByZero(uint n) public {
        uint d = 0;
        vm.expectRevert(ZeroDenominator.selector);
        RationalMath.from(n, d);
    }

    function testFromUint(uint integer) public {
        Rational memory r = RationalMath.from(integer);
        assertEq(r.numerator, integer);
        assertEq(r.denominator, 1);
    }

    function testFromRational(uint n, uint d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        Rational memory r = RationalMath.from(n, d);
        Rational memory rr = RationalMath.from(r);
        assertEq(rr.numerator, r.numerator);
        assertEq(rr.denominator, r.denominator);

        // changing rr not affects r
        r.numerator--;
        r.denominator--;
        assertGt(rr.numerator, r.numerator);
        assertGt(rr.denominator, r.denominator);
    }

    function testFromFixed(uint n, uint8 decimals) public {
        if (decimals > 77) decimals = 77;
        Rational memory r = RationalMath.fromFixed(n, decimals);
        assertEq(r.numerator, n);
        assertEq(r.denominator, 10**decimals);
    }

    // Constants

    function testZero() public {
        Rational memory r = RationalMath.zero();
        assertEq(r.numerator, 0);
        assertEq(r.denominator, 1);
    }

    function testOne() public {
        Rational memory r = RationalMath.one();
        assertEq(r.numerator, 1);
        assertEq(r.denominator, 1);
    }

    // Reducing

    function testCommonDivisor(uint n, uint d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        uint divisor = RationalMath.commonDivisor(n, d);
        assertEq(n % divisor, 0);
        assertEq(d % divisor, 0);
    }

    function testCommonDivisor_0_1() public {
        uint divisor = RationalMath.commonDivisor(0, 1);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_1_1() public {
        uint divisor = RationalMath.commonDivisor(1, 1);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_2_4() public {
        uint divisor = RationalMath.commonDivisor(2, 4);
        assertEq(divisor, 2);
    }

    function testCommonDivisor_140_96() public {
        uint divisor = RationalMath.commonDivisor(140, 96);
        assertEq(divisor, 4);
    }

    function testCommonDivisor_prime() public {
        uint n = 19999897;
        uint d = 1002299;
        uint divisor = RationalMath.commonDivisor(n, d);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_primeX(uint128 c) public {
        if (c == 0) c = 1;
        uint n = 19995023;
        uint d = 20999941;
        uint divisor = RationalMath.commonDivisor(n *c, d *c);
        assertEq(divisor, c);
    }

    function testReduce_primeX(uint128 m) public {
        if (m == 0) m = 1;
        uint n = 18121667;
        uint d = 1002299;
        Rational memory r = RationalMath.from(n * m, d * m);
        r = r.reduce();
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testReduce0(uint256 d) public {
        if (d == 0) d = 1;
        uint n = 0;
        Rational memory r = RationalMath.from(n, d);
        r = r.reduce();
        assertEq(r.numerator, 0);
        assertEq(r.denominator, 1);
    }

    function testReduce1(uint256 nd) public {
        if (nd == 0) nd = 1;
        Rational memory r = RationalMath.from(nd, nd);
        r = r.reduce();
        assertEq(r.numerator, 1);
        assertEq(r.denominator, 1);
    }

    // Add

    function testAddIntegerTo0(uint128 integer) public {
        Rational memory a = RationalMath.from(0, 1);
        Rational memory b = RationalMath.from(integer);
        Rational memory r = a._add(b);
        assertEq(r.numerator, integer);
        assertEq(r.denominator, a.denominator);
    }

    function testAddTo0(uint128 n, uint128 d) public {
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(0, 1);
        Rational memory b = RationalMath.from(n, d);
        Rational memory r = a._add(b);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testAddInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(integer);
        Rational memory r = a._add(b);
        assertEq(r.numerator, n + integer * d);
        assertEq(r.denominator, a.denominator);

        Rational memory r2 = b._add(a);
        assertEq(r.numerator, r2.numerator);
        assertEq(r.denominator, r2.denominator);
    }

    function testAdd(uint128 n2, uint128 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(n2, d2);
        Rational memory r = a._add(b);
        assertEq(r.numerator, n * d2 + d * n2);
        assertEq(r.denominator, d * d2);

        Rational memory r2 = b._add(a);
        assertEq(r.numerator, r2.numerator);
        assertEq(r.denominator, r2.denominator);
    }

    function testSubInteger(uint128 integer) public {
        Rational memory a = RationalMath.from(type(uint128).max);
        Rational memory b = RationalMath.from(integer);
        Rational memory r = a._sub(b);
        assertEq(r.numerator, uint(type(uint128).max) - integer);
        assertEq(r.denominator, 1);
    }

    function testSub(uint128 n, uint128 d) public {
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(type(uint128).max);
        Rational memory b = RationalMath.from(n, d);
        Rational memory r = a._sub(b);
        assertEq(r.numerator, uint(type(uint128).max) * uint(d) - n);
        assertEq(r.denominator, d);
    }

    function testAddSub(uint64 i, uint64 n, uint64 d) public {
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(i);
        Rational memory b = RationalMath.from(n, d);
        Rational memory r = a._add(b)._sub(b).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    function testSubAdd(uint64 i, uint64 n, uint64 d) public {
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(type(uint128).max - i);
        Rational memory b = RationalMath.from(n, d);
        Rational memory r = a._sub(b)._add(b).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    function testMulInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(integer);
        Rational memory r = a._mul(b);
        assertEq(r.numerator, n * integer);
        assertEq(r.denominator, d);
    }

    function testMul(uint64 n2, uint64 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(n2, d2);
        Rational memory r = a._mul(b);
        assertEq(r.numerator, n * n2);
        assertEq(r.denominator, d * d2);
    }

    function testMul2Sub(uint64 n, uint64 d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(n, d).reduce();
        Rational memory _2 = RationalMath.from(2);
        Rational memory r = a._mul(_2)._sub(a).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }


    function testDivInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(integer);
        Rational memory r = a._div(b);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d * integer);
    }


    function testDiv(uint64 n2, uint64 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        Rational memory a = RationalMath.from(n, d);
        Rational memory b = RationalMath.from(n2, d2);
        Rational memory r = a._div(b);
        assertEq(r.numerator, n * d2);
        assertEq(r.denominator, d * n2);
    }


    function testAddDiv2(uint64 n, uint64 d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        Rational memory a = RationalMath.from(n, d).reduce();
        Rational memory _2 = RationalMath.from(2);
        Rational memory r = a._add(a)._div(_2).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    // TODO sub

}
