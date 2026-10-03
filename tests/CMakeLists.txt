include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}/../src/include
    ${GLIB2_INCLUDE_DIRS}
)

link_directories(
    ${additional_lib_searchpath}
)

IF(APPLE)
    set(test_mac_files test-all-mac.mm)
    set(mac_libraries iconv)
ENDIF()

add_executable (tests main.cpp test-all.cpp ${test_mac_files})
add_executable (imap-operation-lifetime-tests imap-operation-lifetime.cpp)
set(test_libraries MailCore
    ${ZLIB_LIBRARY} ${LIBETPAN_LIBRARY} ${LIBXML_LIBRARY} ${UCHARDET_LIBRARY} sasl2
    ${TIDY_LIBRARY} ${CTEMPLATE_LIBRARY} ssl crypto ${linux_libraries} ${mac_libraries}
    ${GLIB2_LIBRARIES} ${FOUNDATIONFRAMEWORK} ${SECURITYFRAMEWORK} ${CORESERVICESFRAMEWORK}
)
target_link_libraries(tests ${test_libraries})
target_link_libraries(imap-operation-lifetime-tests ${test_libraries})
