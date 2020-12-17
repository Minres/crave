//----------------------------------------------------------------------
//   Copyright 2016 NXP B.V.
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

#ifndef UBUS_SLAVE_AGENT_H_
#define UBUS_SLAVE_AGENT_H_

#include <systemc>
#include <uvm>

// forward class declaration
class ubus_slave_driver;
class ubus_slave_sequencer;
class ubus_slave_monitor;

//------------------------------------------------------------------------------
// Class: ubus_slave_agent
//------------------------------------------------------------------------------

class ubus_slave_agent : public uvm::uvm_agent
{
public:		

  ubus_slave_driver* driver;
  ubus_slave_sequencer* sequencer;
  ubus_slave_monitor* monitor;

  UVM_COMPONENT_UTILS(ubus_slave_agent);

  ubus_slave_agent(uvm::uvm_component_name name);

  virtual void build_phase(uvm::uvm_phase& phase);

  void connect_phase(uvm::uvm_phase& phase);

}; // class ubus_slave_agent

#endif /* UBUS_SLAVE_AGENT_H_ */

