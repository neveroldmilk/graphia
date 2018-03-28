include(${CMAKE_CURRENT_SOURCE_DIR}/../unity.cmake)

set(CRYPTOPP_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/algparam.cpp
    ${CMAKE_CURRENT_LIST_DIR}/asn.cpp
    ${CMAKE_CURRENT_LIST_DIR}/basecode.cpp
    ${CMAKE_CURRENT_LIST_DIR}/dessp.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ecp.cpp
    ${CMAKE_CURRENT_LIST_DIR}/filters.cpp
    ${CMAKE_CURRENT_LIST_DIR}/fips140.cpp
    ${CMAKE_CURRENT_LIST_DIR}/gf2n.cpp
    ${CMAKE_CURRENT_LIST_DIR}/gfpcrypt.cpp
    ${CMAKE_CURRENT_LIST_DIR}/hmac.cpp
    ${CMAKE_CURRENT_LIST_DIR}/hrtimer.cpp
    ${CMAKE_CURRENT_LIST_DIR}/integer.cpp
    ${CMAKE_CURRENT_LIST_DIR}/misc.cpp
    ${CMAKE_CURRENT_LIST_DIR}/modes.cpp
    ${CMAKE_CURRENT_LIST_DIR}/mqueue.cpp
    ${CMAKE_CURRENT_LIST_DIR}/nbtheory.cpp
    ${CMAKE_CURRENT_LIST_DIR}/oaep.cpp
    ${CMAKE_CURRENT_LIST_DIR}/osrng.cpp
    ${CMAKE_CURRENT_LIST_DIR}/pkcspad.cpp
    ${CMAKE_CURRENT_LIST_DIR}/pssr.cpp
    ${CMAKE_CURRENT_LIST_DIR}/pubkey.cpp
    ${CMAKE_CURRENT_LIST_DIR}/queue.cpp
    ${CMAKE_CURRENT_LIST_DIR}/randpool.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rdtables.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rijndael.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rng.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rsa.cpp
)

if(UNITY_BUILD)
    GenerateUnity(ORIGINAL_SOURCES CRYPTOPP_SOURCES UNITY_PREFIX "cryptopp")
endif()

list(APPEND SOURCES
    ${CRYPTOPP_SOURCES}

    ${CMAKE_CURRENT_LIST_DIR}/cryptlib.cpp
    ${CMAKE_CURRENT_LIST_DIR}/cpu.cpp

    ${CMAKE_CURRENT_LIST_DIR}/des.cpp
    ${CMAKE_CURRENT_LIST_DIR}/dll.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ec2n.cpp
    ${CMAKE_CURRENT_LIST_DIR}/hex.cpp
    ${CMAKE_CURRENT_LIST_DIR}/iterhash.cpp
    ${CMAKE_CURRENT_LIST_DIR}/sha.cpp
)

if(MSVC)
    list(APPEND SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/rdrand.asm
        ${CMAKE_CURRENT_LIST_DIR}/winpipes.cpp
        ${CMAKE_CURRENT_LIST_DIR}/x64dll.asm
        ${CMAKE_CURRENT_LIST_DIR}/x64masm.asm
    )
endif()
