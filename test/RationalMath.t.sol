// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RationalMath.sol";
import "forge-std/console.sol";

contract RationalTest is Test {
    using Rational for rational;

    function setUp() public {
    }

    // From

    function testFromFraction(uint n, uint d) public {
        if (d == 0) d = 1;
        rational memory r = Rational.from(n, d);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testFromFractionDivByZero(uint n) public {
        uint d = 0;
        vm.expectRevert(ZeroDenominator.selector);
        Rational.from(n, d);
    }

    function testFromUint(uint integer) public {
        rational memory r = Rational.from(integer);
        assertEq(r.numerator, integer);
        assertEq(r.denominator, 1);
    }

    function testFromRational(uint n, uint d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        rational memory r = Rational.from(n, d);
        rational memory rr = Rational.from(r);
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
        rational memory r = Rational.fromFixed(n, decimals);
        assertEq(r.numerator, n);
        assertEq(r.denominator, 10**decimals);
    }

    // Constants

    function testZero() public {
        rational memory r = Rational.zero();
        assertEq(r.numerator, 0);
        assertEq(r.denominator, 1);
    }

    function testOne() public {
        rational memory r = Rational.one();
        assertEq(r.numerator, 1);
        assertEq(r.denominator, 1);
    }

    // Reducing

    function testCommonDivisor(uint n, uint d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        uint divisor = Rational.commonDivisor(n, d);
        assertEq(n % divisor, 0);
        assertEq(d % divisor, 0);
    }

    function testCommonDivisor_0_1() public {
        uint divisor = Rational.commonDivisor(0, 1);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_1_1() public {
        uint divisor = Rational.commonDivisor(1, 1);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_2_4() public {
        uint divisor = Rational.commonDivisor(2, 4);
        assertEq(divisor, 2);
    }

    function testCommonDivisor_140_96() public {
        uint divisor = Rational.commonDivisor(140, 96);
        assertEq(divisor, 4);
    }

    function testCommonDivisor_prime() public {
        uint n = 19999897;
        uint d = 1002299;
        uint divisor = Rational.commonDivisor(n, d);
        assertEq(divisor, 1);
    }

    function testCommonDivisor_primeX(uint128 c) public {
        if (c == 0) c = 1;
        uint n = 19995023;
        uint d = 20999941;
        uint divisor = Rational.commonDivisor(n *c, d *c);
        assertEq(divisor, c);
    }

    function testReduce_primeX(uint128 m) public {
        if (m == 0) m = 1;
        uint n = 18121667;
        uint d = 1002299;
        rational memory r = Rational.from(n * m, d * m);
        r = r.reduce();
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testReduce0(uint256 d) public {
        if (d == 0) d = 1;
        uint n = 0;
        rational memory r = Rational.from(n, d);
        r = r.reduce();
        assertEq(r.numerator, 0);
        assertEq(r.denominator, 1);
    }

    function testReduce1(uint256 nd) public {
        if (nd == 0) nd = 1;
        rational memory r = Rational.from(nd, nd);
        r = r.reduce();
        assertEq(r.numerator, 1);
        assertEq(r.denominator, 1);
    }

    // Add

    function testAddIntegerTo0(uint128 integer) public {
        rational memory a = Rational.from(0, 1);
        rational memory b = Rational.from(integer);
        rational memory r = a._add(b);
        assertEq(r.numerator, integer);
        assertEq(r.denominator, a.denominator);
    }

    function testAddTo0(uint128 n, uint128 d) public {
        if (d == 0) d = 1;
        rational memory a = Rational.from(0, 1);
        rational memory b = Rational.from(n, d);
        rational memory r = a._add(b);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d);
    }

    function testAddInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(integer);
        rational memory r = a._add(b);
        assertEq(r.numerator, n + integer * d);
        assertEq(r.denominator, a.denominator);

        rational memory r2 = b._add(a);
        assertEq(r.numerator, r2.numerator);
        assertEq(r.denominator, r2.denominator);
    }

    function testAdd(uint128 n2, uint128 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(n2, d2);
        rational memory r = a._add(b);
        assertEq(r.numerator, n * d2 + d * n2);
        assertEq(r.denominator, d * d2);

        rational memory r2 = b._add(a);
        assertEq(r.numerator, r2.numerator);
        assertEq(r.denominator, r2.denominator);
    }

    function testSubInteger(uint128 integer) public {
        rational memory a = Rational.from(type(uint128).max);
        rational memory b = Rational.from(integer);
        rational memory r = a._sub(b);
        assertEq(r.numerator, uint(type(uint128).max) - integer);
        assertEq(r.denominator, 1);
    }

    function testSub(uint128 n, uint128 d) public {
        if (d == 0) d = 1;
        rational memory a = Rational.from(type(uint128).max);
        rational memory b = Rational.from(n, d);
        rational memory r = a._sub(b);
        assertEq(r.numerator, uint(type(uint128).max) * uint(d) - n);
        assertEq(r.denominator, d);
    }

    function testAddSub(uint64 i, uint64 n, uint64 d) public {
        if (d == 0) d = 1;
        rational memory a = Rational.from(i);
        rational memory b = Rational.from(n, d);
        rational memory r = a._add(b)._sub(b).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    function testSubAdd(uint64 i, uint64 n, uint64 d) public {
        if (d == 0) d = 1;
        rational memory a = Rational.from(type(uint128).max - i);
        rational memory b = Rational.from(n, d);
        rational memory r = a._sub(b)._add(b).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    function testMulInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(integer);
        rational memory r = a._mul(b);
        assertEq(r.numerator, n * integer);
        assertEq(r.denominator, d);
    }

    function testMul(uint64 n2, uint64 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(n2, d2);
        rational memory r = a._mul(b);
        assertEq(r.numerator, n * n2);
        assertEq(r.denominator, d * d2);
    }

    function testMul2Sub(uint64 n, uint64 d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        rational memory a = Rational.from(n, d).reduce();
        rational memory _2 = Rational.from(2);
        rational memory r = a._mul(_2)._sub(a).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }


    function testDivInteger(uint128 integer) public {
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(integer);
        rational memory r = a._div(b);
        assertEq(r.numerator, n);
        assertEq(r.denominator, d * integer);
    }


    function testDiv(uint64 n2, uint64 d2) public {
        if (d2 == 0) d2 = 1;
        uint n = 18121667;
        uint d = 1002299;
        rational memory a = Rational.from(n, d);
        rational memory b = Rational.from(n2, d2);
        rational memory r = a._div(b);
        assertEq(r.numerator, n * d2);
        assertEq(r.denominator, d * n2);
    }

    function testAddDiv2(uint64 n, uint64 d) public {
        if (n == 0) n = 1;
        if (d == 0) d = 1;
        rational memory a = Rational.from(n, d).reduce();
        rational memory _2 = Rational.from(2);
        rational memory r = a._add(a)._div(_2).reduce();
        assertEq(r.numerator, a.numerator);
        assertEq(r.denominator, a.denominator);
    }

    // Downgrade

    function testSignificantBitsMax256() public {
        uint bit = Rational.significantBits(type(uint256).max);
        assertEq(bit, 256);
    }

    function testSignificantBitsMax128() public {
        uint bit = Rational.significantBits(type(uint128).max);
        assertEq(bit, 128);
    }

    function testSignificantBitsMax64() public {
        uint bit = Rational.significantBits(type(uint64).max);
        assertEq(bit, 64);
    }

    function testSignificantBitsMax32() public {
        uint bit = Rational.significantBits(type(uint32).max);
        assertEq(bit, 32);
    }

    function testSignificantBitsMax16() public {
        uint bit = Rational.significantBits(type(uint16).max);
        assertEq(bit, 16);
    }

    function testSignificantBitsMax8() public {
        uint bit = Rational.significantBits(type(uint8).max);
        assertEq(bit, 8);
    }

    function testSignificantBits1() public {
        uint bit = Rational.significantBits(1);
        assertEq(bit, 1);
    }

    function testSignificantBits0() public {
        uint bit = Rational.significantBits(0);
        assertEq(bit, 0);
    }

    function testSignificantBits(uint8 b) public {
        uint num = 1 << b;
        uint bit = Rational.significantBits(num);
        assertEq(bit, uint(b) + 1);
    }

}
